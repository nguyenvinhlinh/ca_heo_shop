# 028-04 Truncate Collection Image File Name

## Goal

Fix broken layout when uploading collection image with a very long file name.

Example problematic file name:

```text
z4883250107721_56958db16d413f2ffa07090ee6d1da02.jpg
```

Current file input HTML from browser:

```html
<input
  data-phx-id="m22-phx-GLiIuhQStpw9cRxF"
  data-phx-loc="3343"
  id="phx-GLiIujNhi99IgCZE"
  type="file"
  name="collection_image"
  accept=".png,.jpg,.jpeg"
  data-phx-hook="Phoenix.LiveFileUpload"
  data-phx-upload-ref="phx-GLiIujNhi99IgCZE"
  data-phx-active-refs="10"
  data-phx-done-refs=""
  data-phx-preflighted-refs=""
  class="file-input file-input-bordered w-full truncate"
/>
```

Even though the input already has `truncate`, the layout can still break when the selected file name is too long.

The goal is to make the collection image upload UI safe for long file names.

## Context

This is a UI layout issue only.

The uploaded file name should not be changed in database or storage.

Only the display of the file name should be truncated or safely constrained.

## Requirements

### 1. Fix long file name overflow in collection image upload input

Update the collection image upload UI so that long selected file names do not break the layout.

Current class:

```html
class="file-input file-input-bordered w-full truncate"
```

This may not be enough because native file input rendering can behave differently across browsers.

The file input should be placed inside a constrained wrapper.

Suggested structure:

```heex
<div class="w-full max-w-full min-w-0 overflow-hidden">
  <.live_file_input
    upload={@uploads.collection_image}
    class="file-input file-input-bordered w-full max-w-full"
  />
</div>
```

Important CSS behavior:

* Parent container should have `max-w-full`
* Parent container should have `min-w-0` when inside flex/grid layout
* Parent container should hide overflow if needed
* File input should not force parent layout wider than available width

### 2. Truncate displayed selected file name

If selected upload entries are rendered manually, truncate `entry.client_name`.

Example:

```heex
<%= for entry <- @uploads.collection_image.entries do %>
  <div class="w-full max-w-full min-w-0 overflow-hidden">
    <span
      class="block max-w-full truncate text-sm"
      title={entry.client_name}
    >
      <%= entry.client_name %>
    </span>
  </div>
<% end %>
```

Expected behavior:

* Long file name is displayed with ellipsis.
* Layout does not overflow horizontally.
* Full file name is still accessible through `title`.
* Short file name still displays normally.

### 3. Do not mutate the real file name

Do not change the original uploaded file name.

Do not truncate before saving.

Do not rename the uploaded file as part of this task.

The following values must remain unchanged:

* `entry.client_name`
* Stored image file name
* Database `image_file_name`
* File name on disk

This task only changes UI display behavior.

### 4. Apply fix to collection image UI

Apply the fix to collection image upload area.

Target page:

* Collection edit page

Also check any place where collection image file name is displayed.

If `collection.image_file_name` is rendered in the UI, make sure it is safely truncated too.

Example:

```heex
<span
  class="block max-w-full truncate"
  title={@collection.image_file_name}
>
  <%= @collection.image_file_name %>
</span>
```

### 5. Prefer reusable class pattern

Use a consistent class pattern for long file name display.

Suggested pattern:

```html
class="block max-w-full truncate"
```

When inside flex or grid layout, make sure the parent or flex child has:

```html
class="min-w-0"
```

This is important because `truncate` often does not work correctly inside flex/grid unless the container can shrink.

## Acceptance Criteria

* Uploading image with long file name does not break the layout.
* File input does not overflow outside its container.
* Selected file name is truncated or visually constrained.
* Full file name is available through tooltip using `title` where file name is rendered manually.
* Short file names still display normally.
* Original file name is not changed.
* Database value is not changed.
* File name on disk is not changed.
* Collection image upload still works.
* Collection image preview still works.
* Collection image delete still works.

## Manual Test Checklist

### Case 1: Long file name

Upload image with file name:

```text
z4883250107721_56958db16d413f2ffa07090ee6d1da02.jpg
```

Expected result:

* Layout does not break.
* No horizontal overflow appears.
* File input stays inside its container.
* Displayed file name is truncated or safely constrained.
* Full file name can be seen through tooltip if rendered manually.
* Image upload still succeeds.

### Case 2: Short file name

Upload image with file name:

```text
collection.jpg
```

Expected result:

* Layout remains normal.
* File name displays normally.
* Image upload still succeeds.

### Case 3: Existing collection image file name

Use existing collection image with long `image_file_name`.

Expected result:

* Existing image file name does not break layout.
* File name display is truncated.
* Full file name is available through tooltip.
* Image preview still displays correctly.

### Case 4: No image

Use collection with:

```elixir
image_file_name == nil
```

Expected result:

* UI does not crash.
* No broken file name text appears.
* No broken image icon appears.

## Notes

The existing class below may not be sufficient by itself:

```html
class="file-input file-input-bordered w-full truncate"
```

Reason:

* `truncate` only works when the element has constrained width.
* In flex/grid layouts, parent elements often need `min-w-0`.
* Native file input text may not fully respect text truncation styling across browsers.

Therefore, prefer fixing both:

1. The parent container width behavior.
2. The manually displayed file name text, if any.

## Out of Scope

This task does not include:

* Renaming uploaded files.
* Changing database schema.
* Changing collection image upload logic.
* Changing thumbnail generation logic.
* Changing collection image delete logic.
* Adding file name length validation.
* Rejecting long file names.
