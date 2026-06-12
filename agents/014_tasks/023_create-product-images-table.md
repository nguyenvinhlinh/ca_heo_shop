# Task 023: Create Product Images Table

## Objective

Create the real `product_images` database table, Ecto schema module, context module, and initial seed data.

This task depends on Task 022 because product images belong to products.

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
research/011-table-products-product-images.md
agents/014_tasks/022_create-product-table.md
```

## Scope

Implement only:

```text
product_images
CaHeoShop.ProductImages.ProductImage
CaHeoShop.ProductImages
product image seed data
```

Do not implement product variants, cart items, orders, inventory, storefront database wiring, or admin database wiring in this task.

## Migration

Generate the migration with:

```text
mix ecto.gen.migration create_product_images
```

Create table:

```text
product_images
```

Fields:

```text
product_id      references products, required
filename        string, required
display_order   integer, required, default 0
inserted_at
updated_at
```

Indexes and constraints:

```elixir
create index(:product_images, [:product_id])
create index(:product_images, [:product_id, :display_order])
create constraint(:product_images, :display_order_must_be_non_negative,
  check: "display_order >= 0"
)
```

`product_id` must reference `products.id` with delete restricted by the database.

## Schema Module

Create:

```text
lib/ca_heo_shop/product_images/product_image.ex
```

Module:

```text
CaHeoShop.ProductImages.ProductImage
```

Requirements:

* Use `Ecto.Schema`.
* Use `Ecto.Changeset`.
* Define all table fields.
* `belongs_to :product, CaHeoShop.Products.Product`.
* Validate required fields: `product_id`, `filename`, `display_order`.
* Validate `display_order >= 0`.
* Add foreign key constraint for `product_id`.
* Add check constraint for `display_order`.

## Context Module

Create:

```text
lib/ca_heo_shop/product_images.ex
```

Module:

```text
CaHeoShop.ProductImages
```

Implement simple CRUD functions for product images:

```text
list_product_images/0
list_product_images_for_product/1
get_product_image!/1
create_product_image/1
update_product_image/2
delete_product_image/1
change_product_image/2
```

`list_product_images_for_product/1` should return images ordered by `display_order ASC`, then `id ASC`.

## Seed Data

Update:

```text
priv/repo/seeds.exs
```

Seed product images idempotently by product slug and filename.

Use existing storefront image filenames where available:

```text
/images/storefront/product-organizer.svg
/images/storefront/category-prints.svg
/images/storefront/product-kit.svg
/images/storefront/category-kits.svg
/images/storefront/product-holder.svg
/images/storefront/category-garden.svg
/images/storefront/custom-order.svg
/images/storefront/hero-workshop.svg
```

Assign `display_order` values starting from `0` for each product.

## Tests

Add focused tests for:

* Product image changeset required fields.
* Non-negative `display_order`.
* Foreign key constraint for `product_id`.
* Listing product images by product in display order.
* Creating, updating, and deleting a product image through `CaHeoShop.ProductImages`.

## Acceptance Criteria

* Migration creates the exact `product_images` table and constraints.
* `CaHeoShop.ProductImages.ProductImage` compiles.
* `CaHeoShop.ProductImages` exposes the required functions.
* Seed data can run more than once without duplicating rows.
* `mix test` passes.
* `mix precommit` passes.
