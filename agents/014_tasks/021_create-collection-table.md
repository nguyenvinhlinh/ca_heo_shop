# Task 021: Create Collections Table

## Objective

Create the real `collections` database table, Ecto schema module, context module, and initial seed data.

This task turns the collections research into implemented application behavior.

## Required Reading

Before starting, read:

```text
AGENTS.md
agents/001_phoenix-agent.md
agents/010_business-context.md
agents/011_architecture.md
agents/012_database-model.md
agents/020_decisions.md
agents/013_task-workflow.md
research/010_table-collections.md
```

## Scope

Implement only:

```text
collections
CaHeoShop.Catalog.Collection
CaHeoShop.Catalog
collection seed data
```

Do not implement products, product images, product variants, cart items, orders, recipients, settings, procedure tables, inventory, or storefront/admin database wiring in this task.

## Migration

Generate the migration with:

```text
mix ecto.gen.migration create_collections
```

Create table:

```text
collections
```

Fields:

```text
name_vi            string, required
name_en            string, required
slug               string, required
description_vi     text, nullable
description_en     text, nullable
image_filename     string, nullable
nav_display_order  integer, nullable
inserted_at
updated_at
```

Indexes and constraints:

```elixir
create unique_index(:collections, [:slug])
create index(:collections, [:nav_display_order])
create constraint(:collections, :nav_display_order_must_be_non_negative,
  check: "nav_display_order IS NULL OR nav_display_order >= 0"
)
```

`nav_display_order` starts from `0` for collections shown in the header navigation.

If `nav_display_order` is `NULL`, the header navigation must not display that collection name when UI wiring is added later.

## Schema Module

Create:

```text
lib/ca_heo_shop/catalog/collection.ex
```

Module:

```text
CaHeoShop.Catalog.Collection
```

Requirements:

* Use `Ecto.Schema`.
* Use `Ecto.Changeset`.
* Define all table fields.
* Validate required fields: `name_vi`, `name_en`, `slug`.
* Validate `nav_display_order >= 0` when present.
* Add unique constraint for `slug`.
* Add check constraint for `nav_display_order`.
* Do not add `has_many :products`. Collections do not need to load belonging products in this first schema implementation.

## Context Module

Create:

```text
lib/ca_heo_shop/catalog.ex
```

Module:

```text
CaHeoShop.Catalog
```

Implement simple CRUD functions for collections:

```text
list_collections/0
list_nav_collections/0
get_collection!/1
get_collection_by_slug!/1
create_collection/1
update_collection/2
delete_collection/1
change_collection/2
```

`list_nav_collections/0` must return only rows where `nav_display_order` is not `NULL`, ordered by `nav_display_order ASC`, then `name_vi ASC`.

## Seed Data

Update:

```text
priv/repo/seeds.exs
```

Seed collections idempotently by `slug`.

Initial collections:

```text
3d-printed-products
diy-kits
home-accessories
hydroponics
custom-orders
```

Use bilingual names and descriptions. Use existing storefront image filenames where available.

Assign header-visible collections `nav_display_order` values starting from `0`. Use `NULL` only for collections intentionally hidden from header navigation.

## Tests

Add focused tests for:

* Collection changeset required fields.
* Unique `slug` constraint.
* Non-negative `nav_display_order`.
* `list_nav_collections/0` filters out `NULL` navigation rows.
* `list_nav_collections/0` orders from `0` upward.

## Acceptance Criteria

* Migration creates the exact `collections` table and constraints.
* `CaHeoShop.Catalog.Collection` compiles.
* `CaHeoShop.Catalog` exposes the required functions.
* Seed data can run more than once without duplicating rows.
* `mix test` passes.
* `mix precommit` passes.
