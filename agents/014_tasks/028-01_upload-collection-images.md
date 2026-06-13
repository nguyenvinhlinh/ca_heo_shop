# Task: Enhance Collection CRUD with Image Upload

## Context

This task belongs to **[Collection CRUD]**.

The project already has basic Collection CRUD functionality. We need to add image upload support for `Collection`, but only in the edit flow.

When creating a new `Collection`, there should be no image upload field. After the Collection has been created and has a `collection_id`, the admin can upload an image from the Collection edit page.

## Goal

Add server-side image upload support for existing `Collection` records.

Uploaded images should be stored on the server under a directory configured by the environment variable:

```bash
CA_HEO_SHOP_ASSETS_PATH
```

## Requirements

### 1. Collection create form

When creating a new `Collection`:

* Do not show any image upload field.
* Do not handle image upload in the create flow.
* The create form should only handle basic Collection information.

### 2. Collection edit form

On the Collection edit page:

* Keep the existing Collection edit form.
* Add a separate image upload form beside the existing edit form.
* The image upload form should be independent from the main Collection edit form.
* The image upload form should only appear when the Collection already exists and has a valid `collection_id`.

### 3. Server assets path

The server should read the assets root path from this environment variable:

```bash
CA_HEO_SHOP_ASSETS_PATH
```

Inside this directory, the application will use these subdirectories:

```text
collection_images
product_images
```

For this task, only implement upload behavior for Collection images.

Collection images must be stored in:

```text
$CA_HEO_SHOP_ASSETS_PATH/collection_images
```

The `product_images` directory is part of the shared assets structure, but Product image upload is out of scope for this task.

### 4. Auto-create missing directory

When uploading a Collection image:

* If `CA_HEO_SHOP_ASSETS_PATH` exists but `collection_images` does not exist, create the `collection_images` directory automatically.
* Do not require the developer or admin to create this subdirectory manually.
* If `CA_HEO_SHOP_ASSETS_PATH` is missing, invalid, or not writable, show a clear error message.

Expected directory:

```text
$CA_HEO_SHOP_ASSETS_PATH/collection_images
```

### 5. File naming convention

Uploaded Collection image files must use this format:

```text
#{collection_id}_#{uuid}.png
#{collection_id}_#{uuid}.jpg
```

Examples:

```text
12_550e8400-e29b-41d4-a716-446655440000.png
12_9d5e7d44-81f2-4f7e-bfb1-2f456f790c34.jpg
```

Rules:

* Prefix the filename with `collection_id`.
* Generate a new UUID for every upload.
* Allow only image files with these extensions:

  * `.png`
  * `.jpg`
  * `.jpeg`
* Normalize `.jpeg` to `.jpg` if that matches the project convention.

### 6. File size limit

The uploaded image file size must be limited to:

```text
1MB
```

If the uploaded file is larger than 1MB:

* Reject the upload.
* Show a clear validation error to the admin.
* Do not save the file to the server.
* Do not update the database record.

### 7. Validation

The upload flow should validate:

* A file is selected.
* File size is less than or equal to 1MB.
* File extension is allowed: `.png`, `.jpg`, `.jpeg`.
* MIME/content type is image-related if the current upload system exposes this information.

### 8. Persist image reference

After a successful upload, update the related `Collection` record with the new image reference.

Prefer storing a relative path or filename instead of an absolute server path.

Acceptable examples:

```text
collection_images/12_550e8400-e29b-41d4-a716-446655440000.png
```

or:

```text
12_550e8400-e29b-41d4-a716-446655440000.png
```

Use the convention that best fits the existing codebase.

If the `collections` table already has an image-related field, reuse it.

If the `collections` table does not have an image field yet, add a minimal migration, for example:

```text
image_path
```

or:

```text
image_filename
```

### 9. Replace existing image

If the Collection already has an existing image, uploading a new image should replace it.

The flow should be:

1. Upload the new image to the server.
2. Update the Collection database record to point to the new image.
3. After the database update succeeds, delete the old image file from the server.

Important rules:

* Only delete the old image after the database update succeeds.
* If the new file upload succeeds but the database update fails, do not delete the old image.
* If deleting the old image fails after the database has been updated, do not rollback the database update.
* Log a warning or error if deleting the old image fails.
* Do nothing if the old image path is empty or the old file does not exist.
* Only delete old files inside:

```text
$CA_HEO_SHOP_ASSETS_PATH/collection_images
```

This prevents accidentally deleting files outside the managed upload directory.

## Scope

In scope:

* Add a separate image upload form to the Collection edit page.
* Do not add image upload to the Collection create page.
* Validate uploaded image files.
* Enforce the 1MB file size limit.
* Store uploaded files in `$CA_HEO_SHOP_ASSETS_PATH/collection_images`.
* Automatically create the `collection_images` directory if missing.
* Generate filenames using the `#{collection_id}_#{uuid}.png/jpg` format.
* Update the Collection record with the new image reference.
* Delete the old image file after the database update succeeds.
* Show success and error feedback to the admin.

Out of scope:

* Uploading images during Collection creation.
* Product image upload UI.
* Multiple images per Collection.
* Image cropping.
* Image resizing.
* CDN/S3/cloud storage.
* Image gallery management.
* Background cleanup jobs.

## Acceptance Criteria

* Admin can create a new Collection without seeing any image upload field.
* Admin can edit an existing Collection and see:

  * the existing Collection edit form
  * a separate Collection image upload form beside it
* Uploading a valid `.png`, `.jpg`, or `.jpeg` file under or equal to 1MB succeeds.
* Uploaded files are stored in:

```text
$CA_HEO_SHOP_ASSETS_PATH/collection_images
```

* If `collection_images` does not exist, it is created automatically on the first upload.
* Uploaded filenames follow this format:

```text
#{collection_id}_#{uuid}.png
#{collection_id}_#{uuid}.jpg
```

* The Collection record is updated with the new image reference.
* If the Collection does not have an old image, the upload works normally.
* If the Collection already has an old image:

  * the new image is uploaded
  * the database record is updated to the new image
  * the old image file is deleted only after the database update succeeds
* If the uploaded file is larger than 1MB, the upload is rejected and the database is not updated.
* If the uploaded file type is unsupported, the upload is rejected and the database is not updated.
* The existing Collection edit functionality continues to work.

## Implementation Notes

Prefer using Phoenix LiveView uploads if the Collection CRUD screen is implemented with LiveView.

Consider extracting upload-related logic into a dedicated module, for example:

```text
CaHeoShop.Assets
CaHeoShop.Uploads
Shop.Assets
Shop.Uploads
```

The module should be responsible for:

* Reading `CA_HEO_SHOP_ASSETS_PATH`.
* Resolving the correct subdirectory.
* Creating missing upload directories.
* Validating file extension.
* Validating file size.
* Generating the final filename.
* Copying the uploaded file to the target directory.
* Safely deleting old image files.

Do not hard-code absolute paths in the codebase.
