# Task 028: Implement Admin Collection Edit Page

## Objective

Implement real logic for:

```text
/admin/collections/:slug/edit
```

Replace the current static mock form with a real LiveView-backed edit flow using the `CaHeoShop.Collections` context.

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
agents/014_tasks/027_implement-admin-collection-new.md
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
live "/admin/collections/:slug/edit", AdminLive, :collection_edit
```

This route must remain in:

```text
pipe_through [:browser, :require_authenticated_user]
live_session :require_authenticated_user
```

## Scope

Implement only collection edit behavior.

Do not implement delete behavior in this task.

## Required Behavior

### Record Loading

Load the existing collection by slug using the real context.

Expected lookup:

```text
CaHeoShop.Collections.get_collection_by_slug!/1
```

If the slug does not exist, allow the normal `Ecto.NoResultsError` / LiveView error flow unless the codebase already uses a different explicit fallback pattern nearby.

### Form Behavior

Use a real `to_form/2` form backed by a collection changeset.

The edit form must expose the real collection fields:

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

Support:

* loading existing values
* live validation
* submit handling
* inline error rendering

### Submit Result

On successful update:

* update through `CaHeoShop.Collections.update_collection/2`
* set success flash
* redirect or push navigate to:

```text
/admin/collections
```

On invalid update:

* remain on the form
* show the real errors

### Slug Change

If the admin edits `slug`, persist the new slug normally.

After save, navigate back to the collections index instead of trying to stay on the old edit URL.

That avoids stale-route issues after a slug change.

## Implementation Guidance

Expected implementation area:

```text
lib/ca_heo_shop_web/live/admin_live.ex
```

Recommended approach:

* load the collection for `:collection_edit`
* build `@form` from `change_collection/2`
* reuse the same event pattern as the new page where reasonable
* keep form handling coherent between create and edit flows

## Tests

Add LiveView tests for:

* authenticated user can open `/admin/collections/:slug/edit`
* page loads existing collection data
* invalid update shows errors
* valid update persists changes
* successful update returns to `/admin/collections`

## Acceptance Criteria

* `/admin/collections/:slug/edit` edits real collection rows
* form uses real schema fields and real validation
* slug-based lookup works
* successful update returns to the collections index
* tests pass
* `mix precommit` passes
