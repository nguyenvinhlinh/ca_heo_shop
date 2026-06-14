# Task 039-12: Admin Upload Product Image

## Filename

`039-12_admin_upload_product_image.md`

## Goal

Add image upload behavior to the admin product detail page so an administrator can upload a new product image for an existing product.

Target page:

```text
/admin/products/:id
```

This task adds upload behavior for the `Product images` area on the product detail page.

## Background

Previous tasks created the admin product detail page and added:

```text
readonly product images list
image preview
image selection
image ordering
```

The next step is to allow admins to add new product images directly from the product detail page.

## Route

Use the existing admin product detail route:

```text
/admin/products/:id
```

Do not create a separate full page just for image upload unless the current LiveView structure absolutely requires it.

The upload flow should be implemented inside the product detail page, preferably in the `Product images` section.

## Authorization Requirement

Only authenticated admin users can access and use this feature.

If `/admin/*` authorization already exists, reuse that behavior.

Do not add new role or permission logic in this task.

## Dependencies

This task depends on:

```text
Task 035: admin route authorization exists
Task 039-01: admin product detail shell exists
Task 039-03: product images section exists
Task 039-04: image preview selection exists
Task 039-05: image ordering exists
```

Expected schema:

```text
CaHeoShop.Products.ProductImage
```

Expected context:

```text
CaHeoShop.Products
```

Expected fields:

```text
product_id
filename
display_order
has_thumbnail
```

## Scope

Implement product image upload from the admin product detail page.

Likely files:

```text
lib/ca_heo_shop/products.ex
lib/ca_heo_shop/products/product_image.ex
lib/ca_heo_shop_web/live/product_live.ex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/product_live_test.exs
```

Actual file names may differ depending on the current project structure.

## UI Requirement

Inside the `Product images` section, add an upload action.

Recommended placement:

```text
Product images                         [Upload image]
```

The action may open:

```text
a dialog/modal
or
an inline upload form
```

Prefer the pattern that best matches the existing admin product detail UI.

## Upload Behavior

Admin should be able to:

```text
select one or more image files
submit upload
create ProductImage records linked to the current product
```

New uploaded images should:

```text
belong to the current product only
appear in the Product images list immediately after success
be selectable in Image preview
receive a valid display_order value
```

Recommended display order behavior:

```text
append new images to the end in upload order
```

If there are no existing images, the new image should become the selected preview image automatically.

## Multiple Upload Requirement

This task should support multiple file upload in one submission.

Maximum:

```text
10 files
```

Behavior:

```text
allow selecting up to 10 image files
create one ProductImage record per uploaded file
preserve the relative order of the selected files when assigning display_order
```

If the product already has images, new files should continue from the current highest `display_order`.

If the submission exceeds the upload limit, show a clear validation error and do not create partial unexpected records beyond accepted upload entries.

## File Handling Requirement

The implementation must define clearly where uploaded files are stored and what filename/path format is used by the project.

Use the project’s existing conventions for public image paths if they already exist.

If the project does not yet have a reusable upload helper, add the smallest practical implementation that supports:

```text
saving the original image
persisting the stored filename/path in product_images.filename
```

Do not over-engineer a generic media library in this task.

## Thumbnail Requirement

This task does not need to implement thumbnail generation unless the current image pipeline already requires it for correctness.

If thumbnails are not generated yet during upload, it is acceptable that:

```text
has_thumbnail is false
preview falls back to original image
list rendering falls back to original image
```

If thumbnail generation already exists and can be reused safely, reuse it.

## Validation Requirement

Handle invalid submissions safely.

Examples:

```text
no file selected
unsupported file type if restricted
upload/save failure
```

Errors should keep the admin on the product detail page and show a useful validation or error message.

## Success Behavior

Successful upload should:

```text
create the product image record or records
refresh the images state on the page
close the dialog/form if applicable
show success flash
```

Recommended success flash:

```text
Product image uploaded successfully.
```

If multiple files are uploaded successfully in one submit, a plural success message is also acceptable.

## Do Not Implement

Do not implement:

```text
image deletion
image replacement
image editing/cropping
bulk upload
variant image upload
external storage integration
generic asset manager
SEO/media metadata system
```

This task only adds upload behavior for product-level images.

## Acceptance Criteria

Expected outcome:

```text
admin can upload one or more product images from /admin/products/:id
uploaded images are persisted for the current product
uploaded images appear in Product images immediately
the page remains stable on invalid input
tests cover context and LiveView behavior
```

Recommended verification:

```text
mix test test/ca_heo_shop/products_test.exs
mix test test/ca_heo_shop_web/live/product_live_test.exs
mix test
```
