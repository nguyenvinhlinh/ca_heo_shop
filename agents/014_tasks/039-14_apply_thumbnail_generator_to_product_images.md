# Task 039-14: Apply ThumbnailGenerator To Product Images

## Filename

`039-14_apply_thumbnail_generator_to_product_images.md`

## Goal

Extend the existing `ThumbnailGenerator` so it can generate thumbnails for `ProductImage` records.

Current thumbnail generator already supports collection images.

After this task, the same generator should support both:

```text
collections.image_filename
product_images.filename
```

For product images, the generator should find records where:

```text
product_images.has_thumbnail == false
```

Then generate a 500x500px thumbnail from the original product image file.

After thumbnail generation succeeds:

```text
product_images.has_thumbnail = true
```

## Background

Previous tasks:

```text
028-02 -> generate collection image thumbnail 500x500px
028-04 -> use collection image thumbnail
031 -> product_images table with has_thumbnail
039-11 -> upload original product image file
```

Task `039-11` uploads original product images into:

```text
%{assets_path}/product_images
```

and creates `ProductImage` records with:

```text
has_thumbnail = false
```

This task makes the existing thumbnail generator process those pending product images.

## Important Design Decision

Do not create a second thumbnail generator.

Reuse and extend the existing generator:

```text
CaHeoShop.GenServer.ThumbnailGenerator
```

or the current actual module path if different.

The generator should now process:

```text
Collection images
Product images
```

Do not break existing collection image thumbnail behavior.

## Dependencies

This task depends on:

```text
Task 028-02: ThumbnailGenerator exists for collection images
Task 031: product_images table exists
Task 039-11: product image upload stores original files in %{assets_path}/product_images
```

Expected schemas:

```text
CaHeoShop.Collections.Collection
CaHeoShop.Products.ProductImage
```

Expected contexts:

```text
CaHeoShop.Collections
CaHeoShop.Products
```

Expected storage config:

```elixir
config :ca_heo_shop, :assets_path
```

Expected product image directory:

```text
%{assets_path}/product_images
```

## Scope

Update the existing thumbnail generation flow to support product images.

Likely files:

```text
lib/ca_heo_shop/gen_server/thumbnail_generator.ex
lib/ca_heo_shop/products.ex
lib/ca_heo_shop/products/product_image.ex
lib/ca_heo_shop_web/live/admin/product_live/show.ex
lib/ca_heo_shop_web/live/admin/product_live/show.html.heex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop/gen_server/thumbnail_generator_test.exs
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text
new thumbnail generator process
image upload
image delete
image edit
multiple thumbnail sizes
background job queue
Oban
Broadway
image crop UI
manual thumbnail regenerate button
```

This task only extends the existing `ThumbnailGenerator`.

## Thumbnail Rule

Generate square thumbnails with final size:

```text
500x500px
```

Use the same crop logic as collection thumbnails:

```text
crop center square from original image
scale down to 500x500px
```

Recommended ffmpeg filter:

```text
crop=min(in_w\,in_h):min(in_w\,in_h):(in_w-min(in_w\,in_h))/2:(in_h-min(in_w\,in_h))/2,scale=500:500
```

The final thumbnail should be a square image:

```text
500px width
500px height
```

## Product Image Thumbnail Filename

Product image original filename format:

```text
%{product_id}_%{uuid}.%{file_image_extension}
```

Example original file:

```text
12_550e8400-e29b-41d4-a716-446655440000.jpg
```

Thumbnail filename should append:

```text
_500x500px
```

before the extension.

Example thumbnail file:

```text
12_550e8400-e29b-41d4-a716-446655440000_500x500px.jpg
```

Recommended helper:

```elixir
def product_image_thumbnail_filename(filename) do
  ext = Path.extname(filename)
  root = Path.rootname(filename)

  "#{root}_500x500px#{ext}"
end
```

Do not update `product_images.filename` to the thumbnail filename.

The database should keep the original filename.

Use `has_thumbnail` to decide whether the thumbnail exists.

## Product Image Source Path

Original product image file path:

```text
%{assets_path}/product_images/<filename>
```

Example:

```text
/home/ca_heo_shop/assets/product_images/12_550e8400-e29b-41d4-a716-446655440000.jpg
```

## Product Image Thumbnail Path

Thumbnail file path:

```text
%{assets_path}/product_images/<thumbnail_filename>
```

Example:

```text
/home/ca_heo_shop/assets/product_images/12_550e8400-e29b-41d4-a716-446655440000_500x500px.jpg
```

Keep original and thumbnail in the same `product_images` directory.

## Product Image HTTP Route

Product images are served through:

```text
/product_images/:filename
```

The same route should also serve thumbnail files.

Example original URL:

```text
/product_images/12_550e8400-e29b-41d4-a716-446655440000.jpg
```

Example thumbnail URL:

```text
/product_images/12_550e8400-e29b-41d4-a716-446655440000_500x500px.jpg
```

No new HTTP route is needed.

## Product Image Query Requirement

The generator should find product images where:

```text
has_thumbnail == false
```

Recommended context function:

```elixir
Products.list_product_images_without_thumbnail(limit \\ 20)
```

Expected behavior:

```text
returns ProductImage records where has_thumbnail is false
ordered by inserted_at ascending
limited to a safe batch size
```

Recommended query behavior:

```text
oldest pending product images first
```

Do not select product images where:

```text
has_thumbnail == true
```

## Product Image Update Requirement

Add or reuse context function:

```elixir
Products.mark_product_image_thumbnail_generated(product_image)
```

Expected behavior:

```text
sets has_thumbnail to true
returns {:ok, product_image}
```

Recommended implementation:

```elixir
def mark_product_image_thumbnail_generated(%ProductImage{} = product_image) do
  product_image
  |> ProductImage.changeset(%{has_thumbnail: true})
  |> Repo.update()
end
```

Use the project’s existing changeset style.

## Generator Flow Requirement

The generator should process collection images and product images.

Recommended high-level flow:

```text
handle_info(:generate_thumbnail, state)
  process pending collection images
  process pending product images
  schedule next run
```

or:

```text
handle_info(:generate_thumbnail, state)
  process one pending collection image
  process one pending product image
  schedule next run
```

Either approach is acceptable if it is safe and does not block too long.

Prefer small batches.

## Product Image Thumbnail Generation Flow

For each pending `ProductImage`:

```text
build original file path
build thumbnail file path
check original file exists
run ffmpeg
verify thumbnail file exists
update product_images.has_thumbnail to true
```

Expected success:

```text
thumbnail file exists
ProductImage.has_thumbnail = true
```

Expected failure:

```text
log error
do not crash generator
continue future runs
```

## Missing Original File Behavior

If a `ProductImage` record points to a missing original file:

```text
log warning
do not generate thumbnail
do not crash generator
```

Recommended cleanup behavior:

```text
delete the ProductImage record if the original file is missing
```

Reason:

```text
product image record is unusable without the physical image file
```

If the project prefers not to delete records automatically, then keep the row and log clearly. However, avoid infinite noisy retries.

Preferred behavior for this project:

```text
missing original product image file -> delete ProductImage record
```

Do not touch other product images.

Do not touch product records.

## Invalid Image Behavior

If ffmpeg fails because the source file is not a valid image:

```text
log error
delete original invalid file
delete ProductImage record
do not crash generator
```

Reason:

```text
invalid uploaded product image cannot be displayed or thumbnailed safely
```

Do not set `has_thumbnail = true` if thumbnail generation failed.

## Existing Thumbnail File Behavior

If thumbnail file already exists but `has_thumbnail` is false:

```text
verify thumbnail file exists
set has_thumbnail = true
do not regenerate unless necessary
```

This makes the generator idempotent.

## Idempotency Requirement

Running the generator multiple times should be safe.

If:

```text
has_thumbnail = true
```

then the product image should not be processed again.

If:

```text
has_thumbnail = false
thumbnail file already exists
```

then mark as true instead of generating a duplicate thumbnail.

Do not create duplicate thumbnail files.

## UI Display Update

Update the admin product show page image display logic.

In `Product Images` section:

```text
if product_image.has_thumbnail == true -> display thumbnail
if product_image.has_thumbnail == false -> display original image
```

Reason:

```text
Task 039-11 displays original images because thumbnails did not exist yet.
After this task, thumbnails should be used when available.
```

Expected helper behavior:

```elixir
def product_image_display_filename(product_image) do
  if product_image.has_thumbnail do
    product_image_thumbnail_filename(product_image.filename)
  else
    product_image.filename
  end
end
```

Expected `<img>` URL:

```heex
<img src={~p"/product_images/#{product_image_display_filename(product_image)}"} />
```

Do not require thumbnails to exist before displaying images.

Uploaded images should remain visible immediately after upload.

## View Original Link Requirement

The `View original` link should always point to the original file:

```text
/product_images/:filename
```

Even when the preview/list displays the thumbnail.

Example:

```heex
<a href={~p"/product_images/#{product_image.filename}"} target="_blank">
  View original
</a>
```

## Product Image Preview Requirement

If image preview exists from previous tasks:

```text
has_thumbnail = true -> preview thumbnail
has_thumbnail = false -> preview original
```

The filename display should still show the original filename stored in DB.

## ProductImageController Safety

The existing `ProductImageController` from Task `039-11` should continue to:

```text
serve files from %{assets_path}/product_images only
reject path traversal
return 404 for missing files
```

No controller rewrite is required unless thumbnail filenames are blocked by existing filename validation.

Make sure filenames like this are allowed:

```text
12_550e8400-e29b-41d4-a716-446655440000_500x500px.jpg
```

Allowed filename characters should include:

```text
letters
numbers
hyphen
underscore
dot
```

## Tests

Add or update tests.

## Products Context Tests

Test:

```text
list_product_images_without_thumbnail/1 returns product images with has_thumbnail false
list_product_images_without_thumbnail/1 does not return product images with has_thumbnail true
list_product_images_without_thumbnail/1 orders by inserted_at ascending
mark_product_image_thumbnail_generated/1 sets has_thumbnail to true
```

If helper exists, test:

```text
product_image_thumbnail_filename/1 appends _500x500px before extension
product_image_thumbnail_filename/1 keeps original extension
```

Examples:

```text
12_uuid.jpg -> 12_uuid_500x500px.jpg
12_uuid.png -> 12_uuid_500x500px.png
12_uuid.jpeg -> 12_uuid_500x500px.jpeg
```

## ThumbnailGenerator Tests

Test:

```text
ThumbnailGenerator generates thumbnail for product image with has_thumbnail false
ThumbnailGenerator saves thumbnail in %{assets_path}/product_images
ThumbnailGenerator names thumbnail with _500x500px suffix
ThumbnailGenerator sets ProductImage.has_thumbnail to true after success
ThumbnailGenerator does not process ProductImage with has_thumbnail true
ThumbnailGenerator handles missing original product image safely
ThumbnailGenerator handles invalid original product image safely
ThumbnailGenerator does not crash when product image generation fails
ThumbnailGenerator keeps existing collection image thumbnail behavior working
```

If calling ffmpeg directly in tests is difficult, isolate filename/path/query/update logic and keep ffmpeg integration test minimal.

## LiveView Tests

Add or update tests for:

```text
/admin/products/:id
```

Test:

```text
Product Images list uses original image when has_thumbnail is false
Product Images list uses thumbnail image when has_thumbnail is true
Product image preview uses original image when has_thumbnail is false
Product image preview uses thumbnail image when has_thumbnail is true
View original link always points to original filename
filename display still shows original filename
```

## Controller Tests

Update existing `ProductImageController` tests if needed.

Test:

```text
GET /product_images/:filename serves original product image
GET /product_images/:thumbnail_filename serves product image thumbnail
GET /product_images/:filename rejects unsafe path traversal
GET /product_images/:filename returns 404 for missing file
```

## Manual Verification

Manually verify:

```text
upload product image in /admin/products/:id
ProductImage.has_thumbnail is false immediately after upload
original image is visible immediately after upload
ThumbnailGenerator later creates _500x500px image file
ProductImage.has_thumbnail becomes true
admin product show page then displays thumbnail
View original still opens original image
collection image thumbnails still work
```

## Acceptance Criteria

The task is complete when:

```text
mix test passes
ThumbnailGenerator still processes collection images
ThumbnailGenerator also processes ProductImage records
ProductImage records with has_thumbnail false are selected for thumbnail generation
ProductImage records with has_thumbnail true are not processed
product image thumbnail files are saved in %{assets_path}/product_images
product image thumbnails use _500x500px filename suffix
product image thumbnail is 500x500px
ProductImage.has_thumbnail is set to true after thumbnail generation succeeds
ProductImage.filename remains the original filename
ProductImageController can serve product image thumbnails
/admin/products/:id displays original image when has_thumbnail is false
/admin/products/:id displays thumbnail image when has_thumbnail is true
View original always links to the original product image
missing original product image does not crash ThumbnailGenerator
invalid original product image does not crash ThumbnailGenerator
no duplicate thumbnail files are created
no new thumbnail generator process is created
no image upload behavior is changed
no image delete UI is implemented
```

## Notes

Keep this task focused on applying the existing thumbnail generator to product images.

The generator should become a shared thumbnail worker for:

```text
collection images
product images
```

Future tasks can add:

```text
manual regenerate thumbnail button
multiple thumbnail sizes
thumbnail cleanup when deleting product images
thumbnail status/error tracking
image optimization
```
