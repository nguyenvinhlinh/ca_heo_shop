# 028-03 Delete Collection Image

## Goal

Implement feature to delete an image from a collection.

When admin deletes a collection image:

* Remove the collection image from the UI.
* Delete the original image file.
* Delete all related thumbnail files.
* Update the collection database record:

  * `image_file_name = nil`
  * `has_thumbnail = nil`

## Context

Collection currently supports uploading image and generating thumbnails.

This task adds the reverse action: deleting the image and cleaning up all related image files.

## Requirements

### 1. Add delete button in collection image UI

Add a delete button in the collection image area.

The delete button should only be visible when the collection has an image.

Expected behavior:

* If `collection.image_file_name` exists, show image preview and delete button.
* If `collection.image_file_name` is `nil`, hide the delete button.
* Clicking the delete button triggers a LiveView / LiveComponent event.
* The delete action should not delete the collection record itself.

Example UI:

```text
[Collection Image Preview]

[Delete image]
```

### 2. Delete original collection image file

When admin deletes the image, delete the original image file from storage.

Use the existing collection image storage path convention in the codebase.

The delete logic should be safe:

* If the original image file exists, delete it.
* If the file does not exist, do not crash.
* Do not delete unrelated files.
* Do not delete files belonging to another collection.

### 3. Delete all related thumbnail files

When admin deletes the collection image, also delete all thumbnail files generated from that image.

This includes all thumbnail variants currently supported by the codebase, such as:

```text
collection image thumbnail
500x500 collection image thumbnail
other generated thumbnail variants
```

The implementation should reuse the existing thumbnail naming/path convention.

The delete logic should be defensive:

* Missing thumbnail files should not crash the request.
* Only delete thumbnail files related to the current collection image.
* Do not delete thumbnails from other collections.

### 4. Update collection database record

After deleting image files, update the collection record:

```elixir
%{
  image_file_name: nil,
  has_thumbnail: nil
}
```

Important:

* `image_file_name` must be set to `nil`.
* `has_thumbnail` must be set to `nil`.
* Do not set `has_thumbnail` to `false`.
* Do not delete the collection record.

### 5. Refresh UI after delete

After successful delete:

* Image preview disappears.
* Delete button disappears.
* Collection is shown as having no image.
* Show success flash message.

Suggested flash message:

```text
Collection image deleted successfully.
```

## Suggested Implementation Notes

Search the codebase for existing collection image upload and thumbnail generation logic.

Likely areas to inspect:

```text
collection image upload handler
collection image thumbnail generation helper
collection edit LiveView / LiveComponent
collection schema / changeset
collection context
collection image path helper
```

Prefer creating a reusable helper function for deleting collection image files.

Example:

```elixir
def delete_collection_image_files(collection) do
  # Delete original image file
  # Delete related thumbnail files
  # Ignore missing files safely
end
```

Then update the collection record:

```elixir
Collections.update_collection(collection, %{
  image_file_name: nil,
  has_thumbnail: nil
})
```

Adjust module names, function names, and paths according to the actual codebase.

## Acceptance Criteria

* Admin can delete image from a collection.
* Delete button appears only when collection has an image.
* Clicking delete removes the original image file.
* Clicking delete removes all related thumbnail files.
* Missing image file does not crash the app.
* Missing thumbnail file does not crash the app.
* Collection database record is updated to:

```elixir
image_file_name == nil
has_thumbnail == nil
```

* Collection record itself is not deleted.
* UI refreshes after deletion.
* Image preview no longer appears after deletion.
* Delete button no longer appears after deletion.
* Existing image upload behavior still works.
* Existing thumbnail generation behavior still works.

## Manual Test Checklist

### Normal case

1. Open collection edit page.
2. Upload image to a collection.
3. Confirm image preview appears.
4. Confirm delete button appears.
5. Confirm original image file exists in storage.
6. Confirm thumbnail files exist in storage.
7. Click delete image button.
8. Confirm success flash message appears.
9. Confirm image preview disappears.
10. Confirm delete button disappears.
11. Confirm original image file is deleted.
12. Confirm all related thumbnail files are deleted.
13. Confirm database record:

```elixir
image_file_name == nil
has_thumbnail == nil
```

14. Reload collection edit page.
15. Confirm deleted image does not reappear.

### Edge cases

1. Delete image when original image file is already missing.
2. Delete image when one or more thumbnail files are already missing.
3. Click delete twice quickly.
4. Delete image from one collection and confirm images from other collections are not affected.
5. Upload a new image after deleting the old image.
6. Confirm new image upload and thumbnail generation still work.

## Out of Scope

This task does not include:

* Deleting the collection record.
* Reworking collection image upload.
* Reworking thumbnail generation.
* Adding multi-image support.
* Adding image restore / undo feature.
* Changing existing thumbnail size rules.
