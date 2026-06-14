# Task 039-16: Admin Delete Product From Product Index

## Filename

`039-16_admin_delete_product_from_index.md`

## Goal

Add delete product behavior to the admin product index page.

Target page:

```text
/admin/products
```

In the admin product index table, each product row should have a delete button.

When admin confirms delete:

```text
delete product
delete related product variants
delete related product images
delete original product image files
delete product image thumbnail files
refresh product index list
```

This task uses hard delete.

Do not add soft delete fields.

## Background

Previous tasks:

```text
036 -> admin products index page
039-01 -> admin product detail shell
039-11 -> upload product image
039-13 -> ThumbnailGenerator applies to ProductImages
039-15 -> delete selected product image from admin product show page
```

Product images are stored in:

```text
%{assets_path}/product_images
```

where:

```elixir
config :ca_heo_shop, :assets_path
```

Product image original filename format:

```text
%{product_id}_%{uuid}.%{file_image_extension}
```

Thumbnail filename format:

```text
%{product_id}_%{uuid}_500x500px.%{file_image_extension}
```

## Route

Use the existing admin products index route:

```text
/admin/products
```

Do not create a separate delete page.

Delete should happen from the product index UI.

## Authorization Requirement

Only users with role:

```text
admin
```

can delete products.

If Task 035 already protects `/admin/*`, reuse that behavior.

Do not add new role or permission logic in this task.

## Dependencies

This task depends on:

```text
Task 031: product_images table exists
Task 032: product_variants table exists
Task 035: admin route authorization exists
Task 036: admin products index page exists
Task 039-11: product image upload and /product_images/:filename exist
Task 039-13: product image thumbnail naming exists
Task 039-15: product image file delete behavior exists
```

Expected schemas:

```text
CaHeoShop.Products.Product
CaHeoShop.Products.ProductVariant
CaHeoShop.Products.ProductImage
```

Expected context:

```text
CaHeoShop.Products
```

Expected relationship:

```text
products has many product_variants
products has many product_images
```

## Scope

Implement delete product behavior from `/admin/products`.

Likely files:

```text
lib/ca_heo_shop/products.ex
lib/ca_heo_shop/products/product.ex
lib/ca_heo_shop/products/product_image.ex
lib/ca_heo_shop_web/live/admin/product_live/index.ex
lib/ca_heo_shop_web/live/admin/product_live/index.html.heex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/index_test.exs
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text
soft delete
is_deleted
deleted_at
restore product
bulk delete products
delete collection
delete sale order
delete sale order item
archive product
product visibility status
```

This task only deletes one product from the admin product index page.

## Business Decision

Use hard delete for products.

Do not add:

```text
is_deleted
deleted_at
deleted_by_id
```

When product is deleted, historical sale order display should rely on snapshot fields stored in order items.

If sale order tables already exist, product deletion must not delete sale order history.

## Sale Order Snapshot Safety

Historical order display must not depend on live product records.

If `sale_order_items` already exists and references products or product variants, deleting a product must not delete sale order items.

Preferred behavior:

```text
sale_order_items remain
snapshot fields remain unchanged
product_id becomes nil if needed
product_variant_id becomes nil if needed
```

Do not cascade delete sale order items.

If sale order tables are not implemented yet, no sale order migration is required in this task.

When sale order tables are implemented later, remember:

```text
sale_order_items should use snapshots as historical source of truth
sale_order_items.product_id should not block hard deleting products
sale_order_items.product_variant_id should not block hard deleting product variants
```

## UI Requirement

In `/admin/products`, each product row should have a delete button.

Recommended button label:

```text
Delete
```

Recommended placement:

```text
Actions column
```

Example row actions:

```text
View | Edit | Delete
```

If the index currently has only `View`, add `Delete` next to it.

## Confirmation Requirement

Deleting a product should require confirmation.

Recommended confirmation message:

```text
Delete this product?
```

Better detailed confirmation message:

```text
Delete this product and all related variants and images?
```

Use the project’s existing confirmation pattern if available.

Example:

```heex
<button
  type="button"
  class="btn btn-xs btn-error"
  phx-click="delete-product"
  phx-value-id={product.id}
  data-confirm="Delete this product and all related variants and images?"
>
  Delete
</button>
```

## Delete Behavior

When admin confirms delete:

```text
verify product exists
load product with product_images and product_variants
delete related product image files
delete related product image thumbnail files
delete ProductImage records
delete ProductVariant records
delete Product record
refresh product index list
show success flash
```

Recommended success flash:

```text
Product deleted successfully.
```

Recommended failure flash:

```text
Could not delete product.
```

## Product Image File Delete Requirement

Deleting a product must delete all image files owned by the product.

For every `ProductImage`:

```text
delete original image file
delete thumbnail image file if exists
delete ProductImage database record
```

Original file path:

```text
%{assets_path}/product_images/<filename>
```

Thumbnail file path:

```text
%{assets_path}/product_images/<thumbnail_filename>
```

Example:

```text
original:
12_550e8400-e29b-41d4-a716-446655440000.jpg

thumbnail:
12_550e8400-e29b-41d4-a716-446655440000_500x500px.jpg
```

If the original file is missing:

```text
do not crash
continue cleanup
delete database record
```

If thumbnail file is missing:

```text
do not crash
continue cleanup
```

## Product Image Thumbnail Helper

Reuse the thumbnail filename helper from Task `039-13` or `039-15`.

Expected helper behavior:

```elixir
product_image_thumbnail_filename("12_uuid.jpg")
# => "12_uuid_500x500px.jpg"
```

Do not duplicate inconsistent thumbnail filename logic.

## File Safety Requirement

Never delete files outside:

```text
%{assets_path}/product_images
```

Reject unsafe filenames.

Reject filenames containing:

```text
../
/
\
```

The filename should be a basename only.

Recommended validation:

```elixir
Path.basename(filename) == filename
```

Only delete paths built from:

```elixir
Path.join([assets_path, "product_images", filename])
```

Do not accept raw file paths from client params.

## Products Context Requirement

Update:

```text
lib/ca_heo_shop/products.ex
```

Add a high-level function:

```elixir
delete_product_with_dependencies(%Product{} = product)
```

Expected behavior:

```text
deletes product image files
deletes product image thumbnail files
deletes ProductImage records
deletes ProductVariant records
deletes Product record
returns {:ok, product} on success
returns {:error, reason} on failure
```

Also add or reuse:

```elixir
delete_product(%Product{} = product)
```

if it already exists.

Preferred direction:

```text
delete_product_with_dependencies/1 should be used by the admin product index
```

Reason:

```text
product delete needs file cleanup, not only database delete
```

Do not create a new context.

Keep using:

```text
CaHeoShop.Products
```

Do not create:

```text
CaHeoShop.ProductDeletes
CaHeoShop.ProductImages
CaHeoShop.ProductVariants
```

## Transaction Requirement

Database deletes should be transactional.

Recommended behavior:

```text
delete ProductImage records
delete ProductVariant records
delete Product record
inside one database transaction
```

File deletion cannot be perfectly transactional with database deletion.

Recommended practical flow:

```text
load product with images and variants
validate all image filenames are safe
delete physical files if they exist
run database transaction to delete records
```

If database delete fails after physical files were deleted:

```text
log the error clearly
return {:error, reason}
show failure flash
```

Alternative acceptable flow:

```text
database transaction first
then file delete
```

But if using this flow, make sure file delete failures are logged clearly.

Preferred for this project:

```text
validate filenames
delete files
delete database records in transaction
```

## Product Variant Delete Requirement

Deleting a product should also delete related product variants.

Expected behavior:

```text
all product_variants where product_id == product.id are deleted
```

Do not require deleting variants one by one through UI events.

Do not normalize variant display order.

## ProductImage Delete Requirement

Deleting a product should also delete related product image records.

Expected behavior:

```text
all product_images where product_id == product.id are deleted
```

Do not require deleting images one by one through UI events.

Do not normalize image display order.

## Foreign Key Requirement

Check database foreign keys.

Preferred behavior:

```text
product_images.product_id -> products.id with on_delete: :delete_all
product_variants.product_id -> products.id with on_delete: :delete_all
```

However, even if database cascade exists, this task must still delete physical product image files before or during product deletion.

Do not rely only on database cascade, because physical files would remain orphaned.

## LiveView Event Requirement

Add event:

```text
delete-product
```

Expected payload:

```elixir
%{"id" => product_id}
```

Expected behavior:

```text
find product from current index result or load by id
call Products.delete_product_with_dependencies(product)
refresh product index entries with current params
show success or failure flash
```

Do not blindly trust product id from params without loading the product.

If product does not exist:

```text
show error flash or ignore safely
do not crash
```

Recommended error flash:

```text
Product not found.
```

## Product Index Refresh Requirement

After successful delete:

```text
refresh products list
refresh total_count
refresh pagination summary
keep current filters/search/per_page when possible
```

If current page becomes empty after deletion and page > 1:

```text
go to previous valid page
```

Example:

```text
before:
page = 3
only one product on page 3

delete product

after:
page should become 2 if page 3 is now empty
```

Do not require full browser reload.

LiveView assign update is preferred.

## Search And Filter Preservation

If admin is viewing `/admin/products` with params such as:

```text
?page=2&per_page=20&q=phone&collection=3
```

after delete, preserve:

```text
q
collection
per_page
```

Adjust `page` only if necessary.

## Empty State Requirement

If no products remain after deletion:

```text
show empty state
show total_count = 0
show pagination summary 0-0 of 0
```

The page should not crash.

## Product Detail Link Behavior

If the deleted product had a detail page open in another tab, that page may later return not found.

No special handling is required in this task.

## Tests

Add or update tests.

## Products Context Tests

Test:

```text
delete_product_with_dependencies/1 deletes Product record
delete_product_with_dependencies/1 deletes related ProductVariant records
delete_product_with_dependencies/1 deletes related ProductImage records
delete_product_with_dependencies/1 deletes original product image files
delete_product_with_dependencies/1 deletes thumbnail product image files if they exist
delete_product_with_dependencies/1 succeeds when original image file is missing
delete_product_with_dependencies/1 succeeds when thumbnail image file is missing
delete_product_with_dependencies/1 does not delete other products
delete_product_with_dependencies/1 does not delete other product variants
delete_product_with_dependencies/1 does not delete other product images
delete_product_with_dependencies/1 rejects unsafe filenames
delete_product_with_dependencies/1 does not delete files outside %{assets_path}/product_images
```

If sale order tables already exist, test:

```text
deleting product does not delete sale_order_items
deleting product preserves sale_order_item snapshot fields
```

Only add sale order tests if sale order tables already exist.

## LiveView Tests

Add tests for:

```text
/admin/products
```

### Rendering Tests

Test:

```text
product row renders Delete button
Delete button has confirmation
Delete button sends delete-product event
```

### Delete Success Test

Test:

```text
admin clicks Delete for a product
product is deleted
success flash is shown
product disappears from index list
total_count updates
pagination summary updates
```

### Delete Product With Variants Test

Test:

```text
admin deletes product with variants
related product variants are deleted
```

### Delete Product With Images Test

Test:

```text
admin deletes product with product images
related ProductImage records are deleted
original image files are deleted
thumbnail image files are deleted if they exist
```

### Delete Last Product On Page Test

Test:

```text
admin deletes last product on current page
page adjusts to previous valid page if needed
index does not show empty invalid page
```

### Empty State Test

Test:

```text
admin deletes the only product
empty state is shown
pagination summary shows 0-0 of 0
```

### Search And Filter Preservation Test

Test:

```text
admin deletes product while q filter is active
q filter is preserved
admin deletes product while collection filter is active
collection filter is preserved
admin deletes product while per_page is selected
per_page is preserved
```

### Missing Product Test

Test:

```text
delete-product event with missing product id does not crash
error flash or safe ignore happens
```

### Existing Page Behavior Test

Verify existing index behavior still works:

```text
search still works
collection filter still works
pagination still works
per_page select still works
product detail links still work
thumbnail/original image display still works
```

## Manual Verification

Manually verify:

```text
open /admin/products
delete a product without images
delete a product with variants
delete a product with product images
confirm Product row is removed
confirm ProductVariant rows are removed
confirm ProductImage rows are removed
confirm original image files are removed from %{assets_path}/product_images
confirm thumbnail image files are removed from %{assets_path}/product_images
confirm collection records remain
confirm other products remain
confirm search/filter/pagination still work
```

## Authorization Tests

If earlier tasks already cover admin index authorization, do not duplicate too much.

At minimum, verify:

```text
admin can delete product
customer cannot access /admin/products
system cannot access /admin/products
anonymous user redirects to login
```

## Acceptance Criteria

The task is complete when:

```text
mix test passes
/admin/products still works
each product row has Delete button
Delete button asks for confirmation
admin can delete one product from index
Product record is hard deleted
related ProductVariant records are deleted
related ProductImage records are deleted
original product image files are deleted
thumbnail product image files are deleted if they exist
missing original image file does not crash delete flow
missing thumbnail image file does not crash delete flow
unsafe filenames cannot delete files outside %{assets_path}/product_images
product disappears from index after delete
total_count updates after delete
pagination summary updates after delete
current search/filter/per_page are preserved after delete
current page adjusts if deleting last item makes page invalid
empty state works after deleting all products
collection records are not deleted
sale order history is not deleted if sale order tables exist
no soft delete field is added
no bulk delete behavior is implemented
no restore behavior is implemented
```

## Notes

Keep this task focused on deleting one product from the admin product index.

Deleting product means deleting owned child data:

```text
product_variants
product_images
original product image files
500x500px thumbnail image files
```

Future tasks can add:

```text
bulk product delete
product archive / visibility status
restore product
delete confirmation modal with product name typing
audit log
```
