# 028-04 Use Collection Thumbnail Image

## Goal

Use collection thumbnail image when displaying collection images in admin pages.

Target pages:

* Collection index page
* Collection edit page

Expected display rule:

* If `collection.has_thumbnail == true`, use thumbnail image.
* If `collection.has_thumbnail == false`, use original image.
* If `collection.has_thumbnail == nil`, treat it as no thumbnail and use original image when `image_file_name` exists.

## Context

Collection image upload now supports thumbnail generation.

Some collection records may have thumbnail files, while some records may only have the original image.

The UI should prefer thumbnail images when available because they are smaller and better suited for preview display.

## Requirements

### 1. Update collection image display logic

Update the image rendering logic for collections.

When rendering a collection image:

```elixir
if collection.has_thumbnail == true do
  # use thumbnail image path
else
  # use original image path
end
```

Important behavior:

* `has_thumbnail == true` means thumbnail image should be used.
* `has_thumbnail == false` means original image should be used.
* `has_thumbnail == nil` should not crash the UI.
* If `image_file_name == nil`, do not render an image.

### 2. Apply logic in collection index page

In the collection index page, collection image preview should use:

* Thumbnail image when `has_thumbnail == true`
* Original image when `has_thumbnail == false`
* Original image when `has_thumbnail == nil` and `image_file_name` exists
* No image when `image_file_name == nil`

### 3. Apply logic in collection edit page

In the collection edit page, collection image preview should use the same image selection logic:

* Thumbnail image when `has_thumbnail == true`
* Original image when `has_thumbnail == false`
* Original image when `has_thumbnail == nil` and `image_file_name` exists
* No image when `image_file_name == nil`

### 4. Reuse existing path conventions

Use the existing collection image path and thumbnail path conventions from the codebase.

Do not introduce a new unrelated image path convention.

Search existing code for:

```text
collection image path
collection thumbnail path
collection image upload
collection image preview
```

### 5. Prefer reusable helper

Prefer creating a reusable helper function for choosing the correct display image path.

Example idea:

```elixir
def collection_display_image_path(collection) do
  cond do
    is_nil(collection.image_file_name) ->
      nil

    collection.has_thumbnail == true ->
      collection_thumbnail_image_path(collection)

    true ->
      collection_original_image_path(collection)
  end
end
```

Adjust function name and module name based on the actual codebase.

The goal is to avoid duplicating image selection logic in multiple templates.

## Acceptance Criteria

* Collection index page displays thumbnail image when `has_thumbnail == true`.
* Collection index page displays original image when `has_thumbnail == false`.
* Collection index page does not crash when `has_thumbnail == nil`.
* Collection edit page displays thumbnail image when `has_thumbnail == true`.
* Collection edit page displays original image when `has_thumbnail == false`.
* Collection edit page does not crash when `has_thumbnail == nil`.
* No image is rendered when `image_file_name == nil`.
* Existing collection image upload still works.
* Existing collection image delete still works.
* Existing thumbnail generation still works.
* Image path logic is reused or centralized where reasonable.

## Manual Test Checklist

### Case 1: Collection has thumbnail

Database state:

```elixir
image_file_name != nil
has_thumbnail == true
```

Expected result:

* Collection index page shows thumbnail image.
* Collection edit page shows thumbnail image.
* Browser image URL points to thumbnail file.

### Case 2: Collection has original image only

Database state:

```elixir
image_file_name != nil
has_thumbnail == false
```

Expected result:

* Collection index page shows original image.
* Collection edit page shows original image.
* Browser image URL points to original image file.

### Case 3: Collection has image but thumbnail flag is nil

Database state:

```elixir
image_file_name != nil
has_thumbnail == nil
```

Expected result:

* Collection index page does not crash.
* Collection edit page does not crash.
* Original image is shown.

### Case 4: Collection has no image

Database state:

```elixir
image_file_name == nil
has_thumbnail == nil
```

Expected result:

* Collection index page does not render image preview.
* Collection edit page does not render image preview.
* UI does not show broken image icon.

## Out of Scope

This task does not include:

* Generating new thumbnails.
* Regenerating missing thumbnails.
* Uploading collection images.
* Deleting collection images.
* Changing thumbnail size rules.
* Changing database schema.
* Adding fallback placeholder image.
