# Task 030: Create Products Table With Nullable Collection

## Objective

Create or revise the real `products` database table, Ecto schema module, context module, and initial seed data so that a product may belong to a collection or may have no collection.

This task changes the earlier assumption that every product must belong to exactly one collection.

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
agents/014_tasks/022_create-product-table.md
research/010_table-collections.md
research/011-table-products-product-images.md
```

## Scope

Implement or revise only:

```text
products
CaHeoShop.Products.Product
CaHeoShop.Products
product seed data
```

Do not implement product images, product variants, cart items, orders, inventory, storefront database wiring, or admin database wiring in this task.

## Core Change

The `products.collection_id` field must be nullable.

Meaning:

```text
A product may belong to a collection.
A product may also exist without any collection.
```

This requirement supersedes the earlier assumption in Task 022 that every product must belong to one collection.

## Migration

If the `products` table does not exist yet, create it with:

```text
mix ecto.gen.migration create_products
```

If the `products` table already exists with `collection_id` required, create a new migration to change it.

Expected table:

```text
products
```

Fields:

```text
collection_id    references collections, nullable
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

`collection_id` should still reference `collections.id` with delete restricted by the database when present.

## Schema Module

Expected module:

```text
CaHeoShop.Products.Product
```

Requirements:

* `belongs_to :collection, CaHeoShop.Collections.Collection`
* `collection_id` is optional
* validate required fields: `slug`, `name_vi`, `name_en`
* do not require `collection_id`
* keep price, cost, stock, and images out of this schema

## Context Module

Expected module:

```text
CaHeoShop.Products
```

Implement or revise CRUD functions:

```text
list_products/0
list_products_by_collection/1
list_uncategorized_products/0
get_product!/1
get_product_by_slug!/1
create_product/1
update_product/2
delete_product/1
change_product/2
```

`list_products_by_collection/1` should continue to support a collection struct or collection id.

`list_uncategorized_products/0` should return products where `collection_id` is `NULL`.

## Seed Data

Update:

```text
priv/repo/seeds.exs
```

Seed products idempotently by `slug`.

At least one seeded product should have:

```text
collection_id = NULL
```

Use bilingual names and descriptions:

```text
name_vi
name_en
description_vi
description_en
```

## Tests

Add focused tests for:

* product changeset does not require `collection_id`
* product can be created with a collection
* product can be created without a collection
* `list_products_by_collection/1` still works
* `list_uncategorized_products/0` returns only products with `NULL` collection

## Acceptance Criteria

* `products.collection_id` is nullable
* `CaHeoShop.Products.Product` compiles with optional collection
* `CaHeoShop.Products` exposes the required functions
* seed data includes at least one uncategorized product
* tests pass
* `mix precommit` passes
