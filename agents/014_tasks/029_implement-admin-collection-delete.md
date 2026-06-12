# Task 029: Implement Admin Collection Delete

## Objective

Implement real logic for:

```text
/admin/collections/:slug/delete
```

Replace the current static mock delete confirmation with a real delete flow using the `CaHeoShop.Collections` context.

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
agents/014_tasks/028_implement-admin-collection-edit.md
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
live "/admin/collections/:slug/delete", AdminLive, :collection_delete
```

This route must remain in:

```text
pipe_through [:browser, :require_authenticated_user]
live_session :require_authenticated_user
```

## Scope

Implement only collection delete behavior.

Do not redesign the generic delete UI unless required to support real behavior.

## Required Behavior

### Record Loading

Load the collection by slug using:

```text
CaHeoShop.Collections.get_collection_by_slug!/1
```

The confirmation page must display real collection information, not mock data.

At minimum, show:

```text
name_vi
name_en
slug
```

### Delete Action

The confirmation page must perform a real delete through:

```text
CaHeoShop.Collections.delete_collection/1
```

On successful delete:

* delete the row
* set success flash
* redirect or push navigate back to:

```text
/admin/collections
```

### Failure Handling

If delete fails because of real database constraints, handle it explicitly.

Important example:

```text
products.collection_id references collections.id with on_delete restrict
```

That means a collection with existing products should not be silently deleted.

Required behavior when delete is blocked:

* do not crash the page
* show an error flash or clear inline error
* keep the user in a sensible admin flow

Recommended message:

```text
Cannot delete this collection while products still belong to it.
```

If implementation requires improving `CaHeoShop.Collections.delete_collection/1` error handling or matching on a foreign key constraint result, do that within this task.

## UI Rules

Keep the existing admin delete confirmation pattern.

Do not replace it with a different page architecture.

Adjust only what is necessary to wire the real record and the real delete action.

## Implementation Guidance

Expected implementation area:

```text
lib/ca_heo_shop_web/live/admin_live.ex
```

Recommended approach:

* load the collection for `:collection_delete`
* wire the confirm action to a real LiveView event
* handle success and failure explicitly

## Tests

Add LiveView tests for:

* authenticated user can open `/admin/collections/:slug/delete`
* page renders the real collection identity
* successful confirm deletes the row
* user returns to `/admin/collections` after successful delete
* delete failure is handled when products still belong to the collection

## Acceptance Criteria

* `/admin/collections/:slug/delete` performs a real delete
* page uses real collection data
* product foreign key restriction is handled cleanly
* successful delete returns to the collections index
* tests pass
* `mix precommit` passes
