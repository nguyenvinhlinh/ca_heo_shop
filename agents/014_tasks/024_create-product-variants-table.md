# Task 024: Create Product Variants Table

## Objective

Create the real `product_variants` database table, Ecto schema module, context module, and initial seed data.

This task depends on Task 022 because product variants belong to products.

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
research/004-commerce-order-flow.md
research/011-table-products-product-images.md
agents/014_tasks/022_create-product-table.md
```

## Scope

Implement only:

```text
product_variants
CaHeoShop.ProductVariants.ProductVariant
CaHeoShop.ProductVariants
product variant seed data
```

Do not implement cart items, orders, inventory movements, storefront database wiring, or admin database wiring in this task.

## Migration

Generate the migration with:

```text
mix ecto.gen.migration create_product_variants
```

Create table:

```text
product_variants
```

Fields:

```text
product_id        references products, required
variant_name      string, required
production_cost   integer, required, default 0
selling_price     integer, required
stock_quantity    integer, required, default 0
image_filename    string, nullable
display_order     integer, required, default 0
inserted_at
updated_at
```

Money fields are integer VND amounts. Do not use floats.

Indexes and constraints:

```elixir
create index(:product_variants, [:product_id])
create index(:product_variants, [:product_id, :display_order])
create unique_index(:product_variants, [:product_id, :variant_name])
create constraint(:product_variants, :production_cost_must_be_non_negative,
  check: "production_cost >= 0"
)
create constraint(:product_variants, :selling_price_must_be_non_negative,
  check: "selling_price >= 0"
)
create constraint(:product_variants, :stock_quantity_must_be_non_negative,
  check: "stock_quantity >= 0"
)
create constraint(:product_variants, :display_order_must_be_non_negative,
  check: "display_order >= 0"
)
```

`product_id` must reference `products.id` with delete restricted by the database.

## Schema Module

Create:

```text
lib/ca_heo_shop/product_variants/product_variant.ex
```

Module:

```text
CaHeoShop.ProductVariants.ProductVariant
```

Requirements:

* Use `Ecto.Schema`.
* Use `Ecto.Changeset`.
* Define all table fields.
* `belongs_to :product, CaHeoShop.Products.Product`.
* Validate required fields: `product_id`, `variant_name`, `production_cost`, `selling_price`, `stock_quantity`, `display_order`.
* Validate `production_cost >= 0`.
* Validate `selling_price >= 0`.
* Validate `stock_quantity >= 0`.
* Validate `display_order >= 0`.
* Add unique constraint for `product_id` plus `variant_name`.
* Add foreign key constraint for `product_id`.
* Add check constraints for all non-negative integer fields.

## Context Module

Create:

```text
lib/ca_heo_shop/product_variants.ex
```

Module:

```text
CaHeoShop.ProductVariants
```

Implement simple CRUD functions for product variants:

```text
list_product_variants/0
list_product_variants_for_product/1
get_product_variant!/1
create_product_variant/1
update_product_variant/2
delete_product_variant/1
change_product_variant/2
```

`list_product_variants_for_product/1` should return variants ordered by `display_order ASC`, then `id ASC`.

## Seed Data

Update:

```text
priv/repo/seeds.exs
```

Seed product variants idempotently by product slug and `variant_name`.

Initial variants:

```text
modular-desk-organizer
- Matte black PLA
- White PLA
- Custom color request

starter-electronics-kit
- Basic kit
- Kit with sensors

custom-plant-holder
- Small cup
- Medium cup
- Custom diameter

prototype-print-request
- Send STL file
- Design assistance
- Repair part
```

Provide reasonable integer VND values for:

```text
production_cost
selling_price
stock_quantity
display_order
```

Use existing image filenames where useful. Seed `display_order` from `0` within each product.

## Tests

Add focused tests for:

* Product variant changeset required fields.
* Unique `product_id` plus `variant_name` constraint.
* Foreign key constraint for `product_id`.
* Non-negative production cost, selling price, stock quantity, and display order.
* Listing variants by product in display order.
* Creating, updating, and deleting a product variant through `CaHeoShop.ProductVariants`.

## Acceptance Criteria

* Migration creates the exact `product_variants` table and constraints.
* Money fields are integer VND amounts.
* `CaHeoShop.ProductVariants.ProductVariant` compiles.
* `CaHeoShop.ProductVariants` exposes the required functions.
* Seed data can run more than once without duplicating rows.
* `mix test` passes.
* `mix precommit` passes.
