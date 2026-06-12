# Task 022: Create Products Table

## Objective

Create the real `products` database table, Ecto schema module, context module, and initial seed data.

This task depends on Task 021 because products belong to collections.

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
research/011-table-products-product-images.md
agents/014_tasks/021_create-collection-table.md
```

## Scope

Implement only:

```text
products
CaHeoShop.Products.Product
CaHeoShop.Products
product seed data
```

Do not implement product images, product variants, cart items, orders, inventory, storefront database wiring, or admin database wiring in this task.

## Migration

Generate the migration with:

```text
mix ecto.gen.migration create_products
```

Create table:

```text
products
```

Fields:

```text
collection_id    references collections, required
slug             string, required
name_vi          string, required
name_en          string, required
description_vi   text, nullable
description_en   text, nullable
inserted_at
updated_at
```

Do not create `description_markdown`.

Indexes and constraints:

```elixir
create index(:products, [:collection_id])
create unique_index(:products, [:slug])
```

`collection_id` must reference `collections.id` with delete restricted by the database.

## Schema Module

Create:

```text
lib/ca_heo_shop/products/product.ex
```

Module:

```text
CaHeoShop.Products.Product
```

Requirements:

* Use `Ecto.Schema`.
* Use `Ecto.Changeset`.
* Define all table fields.
* `belongs_to :collection, CaHeoShop.Collections.Collection`.
* Validate required fields: `collection_id`, `slug`, `name_vi`, `name_en`.
* Add unique constraint for `slug`.
* Add foreign key constraint for `collection_id`.
* Keep price, cost, stock, and images out of this schema. Those belong to variants and images.

## Context Module

Create:

```text
lib/ca_heo_shop/products.ex
```

Module:

```text
CaHeoShop.Products
```

Implement simple CRUD functions for products:

```text
list_products/0
list_products_by_collection/1
get_product!/1
get_product_by_slug!/1
create_product/1
update_product/2
delete_product/1
change_product/2
```

`list_products_by_collection/1` should accept a collection struct or collection id. Keep the implementation simple and explicit.

## Seed Data

Update:

```text
priv/repo/seeds.exs
```

Seed products idempotently by `slug`.

Initial products:

```text
modular-desk-organizer
starter-electronics-kit
custom-plant-holder
prototype-print-request
```

Tie each product to an existing collection by collection slug.

Use bilingual names and descriptions:

* `name_vi`
* `name_en`
* `description_vi`
* `description_en`

## Tests

Add focused tests for:

* Product changeset required fields.
* Unique `slug` constraint.
* Foreign key constraint for `collection_id`.
* Listing products by collection.
* Creating, updating, and deleting a product through `CaHeoShop.Products`.

## Acceptance Criteria

* Migration creates the exact `products` table and constraints.
* `description_markdown` does not exist.
* `CaHeoShop.Products.Product` compiles.
* `CaHeoShop.Products` exposes the required functions.
* Seed data can run more than once without duplicating rows.
* `mix test` passes.
* `mix precommit` passes.
