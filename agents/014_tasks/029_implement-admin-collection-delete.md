# Task 029: Implement Admin Collection Delete

## Objective

Implement real logic for collection delete from:

```text
/admin/collections
```

Replace the current static mock delete confirmation with a real in-page dialog delete flow using the `CaHeoShop.Collections` context.

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

Keep collection delete behavior inside the existing authenticated admin LiveView route:

```text
live "/admin/collections", AdminLive, :collections
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

When the user clicks delete from the index table, load the collection by slug using:

```text
CaHeoShop.Collections.get_collection_by_slug!/1
```

The dialog must display real collection information, not mock data.

At minimum, show:

```text
name_vi
name_en
slug
```

### Delete Action

The dialog confirm action must perform a real delete through:

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

Keep the delete interaction on the collections index page.

Use a dialog or modal pattern that fits the existing admin UI.

Do not navigate to a dedicated delete path.

Adjust only what is necessary to wire the real record and the real delete action.

## Implementation Guidance

Expected implementation area:

```text
lib/ca_heo_shop_web/live/admin_live.ex
```

Recommended approach:

* open a dialog from the collections index
* load the selected collection into LiveView state
* wire the confirm action to a real LiveView event
* handle success and failure explicitly

## Tests

Add LiveView tests for:

* authenticated user can open the delete dialog from `/admin/collections`
* dialog renders the real collection identity
* successful confirm deletes the row
* user returns to `/admin/collections` after successful delete
* delete failure is handled when products still belong to the collection

## Acceptance Criteria

* `/admin/collections` provides real collection delete behavior through a dialog
* dialog uses real collection data
* product foreign key restriction is handled cleanly
* successful delete returns to the collections index state
* tests pass
* `mix precommit` passes
