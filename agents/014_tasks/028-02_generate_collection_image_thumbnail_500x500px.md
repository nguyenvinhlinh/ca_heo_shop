# Task: Generate Collection Image Thumbnail 500x500px

## Filename

```text
028-02_generate_collection_image_thumbnail_500x500px.md
```

## Task ID

```text
028-02_generate_collection_image_thumbnail_500x500px
```

## Context

The project already supports uploading Collection images to the server.

Uploaded Collection images are stored under the configured server assets path:

```bash
CA_HEO_SHOP_ASSETS_PATH
```

Collection images are stored in:

```text
$CA_HEO_SHOP_ASSETS_PATH/collection_images
```

We now need to generate a 500x500px thumbnail for each uploaded Collection image.

This task also defines:

* how to track thumbnail generation state
* how to generate thumbnails using `ffmpeg`
* how to clean up invalid uploaded images
* how to delete Collection images and thumbnails when a Collection is deleted

## Goal

Add automatic thumbnail generation support for Collection images.

When a new Collection is created without an image, its thumbnail state should remain `null`.

When a Collection image is uploaded, the Collection should be marked as not having a thumbnail yet by setting `has_thumbnail` to `false`.

A GenServer named `ThumbnailGenerator` will process Collections where `has_thumbnail == false` and generate a 500x500px thumbnail using `ffmpeg`.

If `ffmpeg` fails to process the uploaded image, the uploaded image should be treated as invalid and removed from the server. The Collection record should also be reset to an image-less state.

## Requirements

### 1. Add `has_thumbnail` column to `collections`

Add a new nullable boolean column to the `collections` table:

```text
has_thumbnail
```

Rules:

* Type: boolean
* Default value: `null`
* Nullable: true
* Existing records should default to `null`
* New Collections created without an uploaded image should have `has_thumbnail == null`
* The field should be available in the Collection schema

Example migration:

```elixir
alter table(:collections) do
  add :has_thumbnail, :boolean, default: nil, null: true
end
```

Meaning:

```text
null  = Collection does not have an uploaded image yet, or thumbnail state is not applicable
false = Collection has an uploaded image, but thumbnail has not been generated yet
true  = Collection has an uploaded image and thumbnail has been generated
```

### 2. Keep `has_thumbnail` as null when creating Collection

When creating a new `Collection`:

* Do not upload an image.
* Do not generate a thumbnail.
* Do not set `has_thumbnail` to `false`.
* Keep `has_thumbnail` as `null`.

Expected value after Collection creation:

```elixir
has_thumbnail == nil
```

### 3. Set `has_thumbnail` to false after image upload

When a Collection image is uploaded successfully:

* Save the uploaded image to the server as usual.
* Update the Collection record with the new image reference.
* Set `has_thumbnail` to `false`.

Expected value after image upload:

```elixir
has_thumbnail == false
```

This must happen every time a new Collection image is uploaded, even if the Collection previously had a generated thumbnail.

### 4. GenServer module location convention

All GenServer modules must be placed under:

```text
lib/ca_heo_shop/gen_server
```

For this task, create the GenServer file at:

```text
lib/ca_heo_shop/gen_server/thumbnail_generator.ex
```

The module name should be:

```elixir
CaHeoShop.GenServer.ThumbnailGenerator
```

Do not place GenServer modules directly under:

```text
lib/ca_heo_shop
```

Do not place this GenServer inside unrelated contexts such as:

```text
lib/ca_heo_shop/catalog
lib/ca_heo_shop/collections
lib/ca_heo_shop_web
```

### 5. Add `ThumbnailGenerator` GenServer

Create a GenServer named:

```elixir
CaHeoShop.GenServer.ThumbnailGenerator
```

The GenServer should:

* Query all Collections where `has_thumbnail == false`.
* Only process Collections that have an image reference.
* Ignore Collections where `has_thumbnail == nil`.
* Loop through the query result.
* Use `ffmpeg` to generate a 500x500px thumbnail.
* After thumbnail generation succeeds, update the Collection record with `has_thumbnail: true`.

Expected query condition:

```elixir
has_thumbnail == false
```

Expected update after successful thumbnail generation:

```elixir
has_thumbnail: true
```

The GenServer should not process Collections where:

```elixir
has_thumbnail == nil
```

because those Collections do not have uploaded images yet.

### 6. Thumbnail file naming convention

The generated thumbnail filename should be based on the original image filename.

Original image format:

```text
#{collection_id}_#{uuid}.jpg
#{collection_id}_#{uuid}.png
```

Thumbnail image format:

```text
#{collection_id}_#{uuid}_500x500px.jpg
#{collection_id}_#{uuid}_500x500px.png
```

Examples:

Original:

```text
12_550e8400-e29b-41d4-a716-446655440000.jpg
```

Thumbnail:

```text
12_550e8400-e29b-41d4-a716-446655440000_500x500px.jpg
```

Original:

```text
12_550e8400-e29b-41d4-a716-446655440000.png
```

Thumbnail:

```text
12_550e8400-e29b-41d4-a716-446655440000_500x500px.png
```

The only filename difference is the added suffix:

```text
_500x500px
```

before the file extension.

### 7. Thumbnail storage location

Generated thumbnails should be stored in the same Collection image directory:

```text
$CA_HEO_SHOP_ASSETS_PATH/collection_images
```

Do not store thumbnails outside the managed Collection image directory.

### 8. Use ffmpeg for thumbnail generation

Use `ffmpeg` to generate the thumbnail image.

The final generated thumbnail must be exactly:

```text
500x500px
```

#### Thumbnail generation logic

The thumbnail must be generated using center-square-crop logic.

Required behavior:

1. Read the original image dimensions.
2. Determine the smaller value between the original image width and height.
3. Crop a square from the center of the original image.
4. Scale the cropped square down to `500x500px`.

This means:

* If the image is landscape, crop the left and right sides evenly.
* If the image is portrait, crop the top and bottom sides evenly.
* The crop center must be the center of the original image.
* The output thumbnail must always be a square image.
* The final output size must always be `500x500px`.
* The thumbnail must not stretch or distort the original image.

#### ffmpeg filter

Use this ffmpeg filter logic:

```text
crop=min(in_w\\,in_h):min(in_w\\,in_h):(in_w-min(in_w\\,in_h))/2:(in_h-min(in_w\\,in_h))/2,scale=500:500
```

When calling `ffmpeg` from Elixir using `System.cmd/2`, use an argument-list style command.

Recommended function shape:

```elixir
def run_ffmpeg_command_500x500px(image_directory, in_image_file_name, out_image_file_name) do
  in_file_path = Path.join([image_directory, in_image_file_name])
  out_file_path = Path.join([image_directory, out_image_file_name])

  cmd_arg_list = [
    "-i",
    in_file_path,
    "-vf",
    "crop=min(in_w\\,in_h):min(in_w\\,in_h):(in_w-min(in_w\\,in_h))/2:(in_h-min(in_w\\,in_h))/2,scale=500:500",
    "-y",
    "-loglevel",
    "quiet",
    out_file_path
  ]

  cmd_output = System.cmd("ffmpeg", cmd_arg_list)

  case cmd_output do
    {_, 0} -> :ok
    _else -> {:error, :run_ffmpeg_command_500x500px}
  end
end
```

Notes:

* Keep the ffmpeg command deterministic and simple.
* Use `-y` so the output thumbnail can be overwritten safely if needed.
* Use `-loglevel quiet` to avoid noisy logs, but still return an error when ffmpeg exits with a non-zero status.
* Since `System.cmd/2` receives an argument list directly, shell escaping is not required for the colon in `scale=500:500`.
* The comma inside `min(in_w\\,in_h)` must remain escaped for the ffmpeg filter expression.

### 9. ffmpeg failure handling

If `ffmpeg` fails for any reason while processing the uploaded Collection image, treat the uploaded image as invalid.

Examples:

* The uploaded file is not a real image.
* The file extension is valid, but the file content is invalid.
* `ffmpeg` cannot read the file.
* `ffmpeg` exits with a non-zero status.
* The thumbnail output file cannot be generated.

When this happens, immediately clean up the invalid uploaded image.

Required behavior:

1. Log the ffmpeg error.
2. Delete the original uploaded image file from the server.
3. Delete the generated thumbnail file if it was partially created.
4. Update the related Collection record:

```elixir
image_filename: nil,
has_thumbnail: nil
```

or, if the project uses another image reference field name:

```elixir
image_path: nil,
has_thumbnail: nil
```

Use the actual image reference field used by the existing `collections` schema.

Important rules:

* Do not keep invalid image files on the server.
* Do not keep the Collection pointing to an invalid image.
* After cleanup, the Collection should return to the same image state as a newly created Collection without an uploaded image.
* File deletion must only happen inside:

```text
$CA_HEO_SHOP_ASSETS_PATH/collection_images
```

This prevents accidental deletion outside the managed upload directory.

### 10. Missing original image file handling

If the Collection record points to an image file, but the original image file does not exist on disk:

* Log the error.
* Update the Collection record:

```elixir
image_filename: nil,
has_thumbnail: nil
```

or use the actual image reference field name from the schema.

The Collection should not be retried forever after this cleanup.

### 11. Database update failure after cleanup

If deleting an invalid image succeeds but updating the Collection record fails:

* Log the database error.
* Do not crash the GenServer.
* Continue processing the next Collection.

If updating the Collection record fails after `ffmpeg` failure cleanup, the system may have a database record pointing to a deleted file. This should be logged clearly so it can be fixed manually if needed.

### 12. Retry behavior

Collections with invalid images should not be retried forever.

After cleanup, the Collection should have:

```elixir
has_thumbnail == nil
```

Because `ThumbnailGenerator` only processes Collections where:

```elixir
has_thumbnail == false
```

the cleaned-up Collection will not be picked up again until the admin uploads a new image.

### 13. Delete Collection cleanup

When deleting a Collection:

* Delete the original Collection image file.
* Delete all thumbnail files related to that Collection image.

For example, if the original image is:

```text
12_550e8400-e29b-41d4-a716-446655440000.jpg
```

Then delete:

```text
12_550e8400-e29b-41d4-a716-446655440000.jpg
12_550e8400-e29b-41d4-a716-446655440000_500x500px.jpg
```

If there may be multiple thumbnail sizes in the future, delete all matching thumbnails for the Collection image.

The delete logic must only delete files inside:

```text
$CA_HEO_SHOP_ASSETS_PATH/collection_images
```

This prevents accidental deletion outside the managed upload directory.

### 14. Safe file deletion rules

All delete operations must be safe.

Before deleting any file:

* Resolve the full absolute path.
* Ensure the resolved file path is inside:

```text
$CA_HEO_SHOP_ASSETS_PATH/collection_images
```

* Do not delete files outside the managed Collection image directory.
* Ignore missing files.
* Log unexpected delete errors.

This rule applies to:

* Deleting invalid uploaded images after ffmpeg failure.
* Deleting partially generated thumbnails after ffmpeg failure.
* Deleting original images and thumbnails when deleting a Collection.

## Scope

In scope:

* Add nullable `has_thumbnail` boolean column to `collections`.
* Update the Collection schema.
* Keep `has_thumbnail == nil` when creating a Collection without an image.
* Set `has_thumbnail` to `false` after Collection image upload.
* Create `CaHeoShop.GenServer.ThumbnailGenerator`.
* Place the GenServer file under `lib/ca_heo_shop/gen_server`.
* Query Collections with `has_thumbnail == false`.
* Generate 500x500px thumbnails using `ffmpeg`.
* Use center-square-crop logic before scaling.
* Store thumbnails beside the original Collection image.
* Update `has_thumbnail` to `true` after successful thumbnail generation.
* On ffmpeg failure, delete the invalid uploaded image and reset the Collection image state.
* On missing original image file, reset the Collection image state.
* Delete the original image and related thumbnails when deleting a Collection.

Out of scope:

* Product image thumbnails.
* Multiple thumbnail sizes.
* Admin UI for manually regenerating thumbnails.
* Background job dashboard.
* Cloud storage.
* CDN support.
* Image optimization beyond basic 500x500px thumbnail generation.
* Advanced virus scanning or deep content inspection.

## Acceptance Criteria

* The `collections` table has a nullable `has_thumbnail` boolean column.
* New Collections created without an image have:

```elixir
has_thumbnail == nil
```

* Existing Collections without images should have:

```elixir
has_thumbnail == nil
```

* After uploading a Collection image, the Collection record has:

```elixir
has_thumbnail == false
```

* The GenServer module exists at:

```text
lib/ca_heo_shop/gen_server/thumbnail_generator.ex
```

* The GenServer module name is:

```elixir
CaHeoShop.GenServer.ThumbnailGenerator
```

* `ThumbnailGenerator` queries only Collections where:

```elixir
has_thumbnail == false
```

* `ThumbnailGenerator` does not process Collections where:

```elixir
has_thumbnail == nil
```

* `ThumbnailGenerator` generates a 500x500px thumbnail using `ffmpeg`.
* Thumbnail generation uses center-square-crop logic before scaling.
* The crop size is based on the smaller value between the original image width and height.
* The square crop is taken from the center of the original image.
* The cropped square is scaled down to exactly `500x500px`.
* The thumbnail must not stretch or distort the original image.
* The ffmpeg command uses this crop filter:

```text
crop=min(in_w\\,in_h):min(in_w\\,in_h):(in_w-min(in_w\\,in_h))/2:(in_h-min(in_w\\,in_h))/2
```

* The ffmpeg command scales the cropped square to:

```text
500x500px
```

* Generated thumbnail filenames follow this format:

```text
#{collection_id}_#{uuid}_500x500px.jpg
#{collection_id}_#{uuid}_500x500px.png
```

* After thumbnail generation succeeds, the Collection record is updated to:

```elixir
has_thumbnail == true
```

* If thumbnail generation fails because `ffmpeg` cannot process the uploaded file, the original uploaded image file is deleted.
* If `ffmpeg` partially creates a thumbnail file before failing, that partial thumbnail file is deleted.
* If `ffmpeg` fails, the Collection record is updated back to:

```elixir
image_filename == nil
has_thumbnail == nil
```

or the equivalent image reference field used by the project.

* If the Collection image file is missing on disk, the Collection record is reset to:

```elixir
image_filename == nil
has_thumbnail == nil
```

or the equivalent image reference field used by the project.

* After ffmpeg failure cleanup, `ThumbnailGenerator` does not retry the same invalid image forever.
* When a Collection is deleted, its original image and all related thumbnails are deleted from the server.
* File deletion is safely limited to:

```text
$CA_HEO_SHOP_ASSETS_PATH/collection_images
```

## Implementation Notes

Prefer placing reusable file-related logic in the existing assets/upload module if one already exists.

Possible helper module names:

```text
CaHeoShop.Assets
CaHeoShop.Uploads
Shop.Assets
Shop.Uploads
```

Useful helper functions may include:

```elixir
collection_images_dir/0
collection_image_path/1
collection_thumbnail_path/1
collection_thumbnail_filename/1
run_ffmpeg_command_500x500px/3
generate_collection_thumbnail/1
delete_collection_image_and_thumbnails/1
safe_delete_collection_image_file/1
reset_collection_image_state/1
```

The `ThumbnailGenerator` GenServer should coordinate the thumbnail generation process, but reusable path, filename, ffmpeg, and deletion logic should stay in a dedicated helper module.

If the GenServer is added to the application supervision tree, reference it using the full module name:

```elixir
CaHeoShop.GenServer.ThumbnailGenerator
```

Keep the first implementation simple. The main purpose is to make thumbnail generation automatic, safe, and retryable.

## Suggested Processing Flow

### Successful flow

```text
Collection image uploaded
        |
        v
Collection image reference saved
has_thumbnail = false
        |
        v
ThumbnailGenerator picks Collection
        |
        v
ffmpeg center-crops the image into a square
        |
        v
ffmpeg scales the square to 500x500px
        |
        v
Collection updated
has_thumbnail = true
```

### ffmpeg failure flow

```text
Collection image uploaded
        |
        v
Collection image reference saved
has_thumbnail = false
        |
        v
ThumbnailGenerator picks Collection
        |
        v
ffmpeg fails
        |
        v
Delete original uploaded image
Delete partially generated thumbnail if any
        |
        v
Reset Collection image state
image_filename = nil
has_thumbnail = nil
```

### Delete Collection flow

```text
Delete Collection requested
        |
        v
Delete original Collection image
Delete related thumbnails
        |
        v
Delete Collection record
```
