# Task 027: Implement Admin Collection New Page

## Objective

Implement real logic for:

```text
/admin/collections/new
```

Replace the current static mock form with a real LiveView-backed create flow using the `CaHeoShop.Collections` context.

## Required Reading

Before starting, read:

```text
AGENTS.md
agents/001_phoenix-agent.md
agents/010_business-context.md
agents/011_architecture.md
agents/012_database-model.md
agents/015_ui-system.md
agents/020_decisions.md
agents/013_task-workflow.md
agents/014_tasks/021_create-collection-table.md
agents/014_tasks/026_implement-admin-collections-index.md
research/001_nexus-design-guideline.md
```

Also inspect:

```text
lib/ca_heo_shop_web/router.ex
lib/ca_heo_shop_web/live/admin_live.ex
lib/ca_heo_shop/collections.ex
lib/ca_heo_shop/collections/collection.ex
```

## Route Scope

Keep this page inside the existing authenticated admin LiveView route:

```text
live "/admin/collections/new", AdminLive, :collection_new
```

This route must remain in:

```text
pipe_through [:browser, :require_authenticated_user]
live_session :require_authenticated_user
```

## Scope

Implement only collection creation behavior.

Do not implement edit or delete behavior in this task.

## Required Behavior

### Form Data

The page must use a real `Phoenix.Component.to_form/2` form backed by a collection changeset.

Use the real schema fields:

```text
name_vi
name_en
slug
description_vi
description_en
image_filename
nav_display_order
```

Do not keep fake fields such as:

```text
status
product_count
```

### Validation

Support normal LiveView form behavior:

* initial blank form
* live validation on change
* submit handling
* inline error rendering from the real changeset

The form must respect existing collection constraints:

* required `name_vi`
* required `name_en`
* required `slug`
* unique `slug`
* `nav_display_order >= 0` when present

### Submit Result

On successful create:

* insert the collection through `CaHeoShop.Collections.create_collection/1`
* set a success flash
* redirect or push navigate back to:

```text
/admin/collections
```

On invalid submit:

* keep the user on the form
* re-render the real validation errors

### UI Rules

Keep the existing admin shell and general page layout.

Use the current collection form page structure as the starting point, but convert it from static inputs to a real form.

The page should remain compact and operational, matching the existing admin UI system.

Suggested field set:

```text
Vietnamese name
English name
Slug
Vietnamese description
English description
Image filename
Navigation display order
```

For `nav_display_order`:

* allow blank input for `NULL`
* explain the hidden-from-header behavior through surrounding label/help text if needed

## Implementation Guidance

Expected implementation area:

```text
lib/ca_heo_shop_web/live/admin_live.ex
```

Recommended approach:

* load a blank `%CaHeoShop.Collections.Collection{}`
* build a changeset through `CaHeoShop.Collections.change_collection/2`
* store a `@form`
* handle `"validate"` and `"save"` events

Keep this inside the existing `AdminLive` unless a clear extraction is needed.

## Tests

Add LiveView tests for:

* authenticated user can open `/admin/collections/new`
* page renders the real form fields
* invalid submission shows errors
* valid submission creates a collection row
* successful create redirects back to `/admin/collections`

## Acceptance Criteria

* `/admin/collections/new` creates real collection rows
* form uses real schema fields and real validation
* `status` and `product_count` are removed from the collection create form
* successful create returns to the collections index
* tests pass
* `mix precommit` passes
