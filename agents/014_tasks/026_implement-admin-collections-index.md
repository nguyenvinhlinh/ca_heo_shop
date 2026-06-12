# Task 026: Implement Admin Collections Index

## Objective

Implement real logic for:

```text
/admin/collections
```

Replace the current mock collection listing on the admin collections index page with data loaded from the real `CaHeoShop.Collections` context.

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
live "/admin/collections", AdminLive, :collections
```

This route must remain in:

```text
pipe_through [:browser, :require_authenticated_user]
live_session :require_authenticated_user
```

Reason:

```text
Admin collection management is an authenticated admin workflow.
```

## Scope

Implement only the index page behavior for listing collections.

Do not implement create, edit, or delete behavior in this task beyond making the index page link to those routes.

## Required Behavior

### Data Loading

Use the real context:

```text
CaHeoShop.Collections
```

Load real collections for the `:collections` live action.

Do not keep using `mock_collections/0` for this page.

### Display Requirements

The table should render real collection data from the database.

Use collection fields that now exist:

```text
name_vi
name_en
slug
description_vi
description_en
image_filename
nav_display_order
updated_at
```

The page should present useful admin information, with a compact Nexus-style table.

Suggested columns:

```text
Name
Slug
Navigation
Description
Updated At
Actions
```

Recommended row behavior:

* Show Vietnamese name as the primary visible name.
* Show English name as secondary muted text.
* Show `slug`.
* Show whether the collection is visible in header navigation.
* Show `nav_display_order` when present.
* If `nav_display_order` is `NULL`, clearly indicate hidden from header navigation.
* Show edit/delete row actions.

Do not invent fake product counts or fake status values if they are not backed by real data.

### Empty State

If there are no collections, show a clean empty state inside the admin page and provide a clear call to action linking to:

```text
/admin/collections/new
```

### UI Rules

Keep the existing admin shell and general page structure.

Do not redesign the page.

Reuse:

* existing `AdminLive`
* existing page header pattern
* existing action button pattern
* existing admin table styling

Adjust only what is necessary to support real collection data.

## Implementation Guidance

Expected implementation area:

```text
lib/ca_heo_shop_web/live/admin_live.ex
```

Possible implementation steps:

* Load collections from `CaHeoShop.Collections`.
* Assign real collection rows in mount or action-specific loading.
* Replace mock collection usage for the index route.
* Add small helper formatting functions if needed for description truncation or nav label rendering.

Prefer action-specific assignment logic over a broad mock-data-only mount path.

## Tests

Add LiveView tests for:

* authenticated user can access `/admin/collections`
* page renders real collection data from seeded or fixture-created rows
* page shows empty state when there are no collections
* hidden navigation collections are rendered clearly as hidden when `nav_display_order` is `NULL`

## Acceptance Criteria

* `/admin/collections` uses real database-backed collection data
* no fake collection rows are shown on the index page
* page remains in the authenticated admin route scope
* index page retains the existing admin UI pattern
* tests pass
* `mix precommit` passes
