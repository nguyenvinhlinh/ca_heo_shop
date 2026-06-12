# Task 025: Create Cart Items Table

## Objective

Create the real `cart_items` database table, Ecto schema module, and context module.

This task depends on Task 024 because cart items reference product variants. It also depends on the existing authentication tables because cart items belong to users as customers.

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
research/012-table-cart-items.md
agents/014_tasks/024_create-product-variants-table.md
```

## Scope

Implement only:

```text
cart_items
CaHeoShop.Carts.CartItem
CaHeoShop.Carts
```

Do not implement checkout, sale orders, sale order items, fulfillment procedures, payment procedures, inventory movements, guest carts, storefront UI database wiring, or admin UI database wiring in this task.

Do not add cart seed data by default. Cart items are user-specific operational data, not catalog seed data.

## Migration

Generate the migration with:

```text
mix ecto.gen.migration create_cart_items
```

Create table:

```text
cart_items
```

Fields:

```text
customer_id          references users, required
product_variant_id   references product_variants, required
quantity             integer, required, default 1
inserted_at
updated_at
```

Indexes and constraints:

```elixir
create index(:cart_items, [:customer_id])
create index(:cart_items, [:product_variant_id])
create unique_index(:cart_items, [:customer_id, :product_variant_id])
create constraint(:cart_items, :quantity_must_be_positive,
  check: "quantity > 0"
)
```

Foreign key behavior:

```text
customer_id references users.id, on_delete delete_all
product_variant_id references product_variants.id, on_delete restrict
```

Do not use `product_id` on cart items. A product alone is not enough to determine selected option, price, cost, or stock.

## Schema Module

Create:

```text
lib/ca_heo_shop/carts/cart_item.ex
```

Module:

```text
CaHeoShop.Carts.CartItem
```

Requirements:

* Use `Ecto.Schema`.
* Use `Ecto.Changeset`.
* Define all table fields.
* `belongs_to :customer, CaHeoShop.Accounts.User`.
* `belongs_to :product_variant, CaHeoShop.ProductVariants.ProductVariant`.
* Validate required fields: `customer_id`, `product_variant_id`, `quantity`.
* Validate `quantity > 0`.
* Add unique constraint for `customer_id` plus `product_variant_id`.
* Add foreign key constraints for `customer_id` and `product_variant_id`.
* Add check constraint for `quantity`.

## Context Module

Create:

```text
lib/ca_heo_shop/carts.ex
```

Module:

```text
CaHeoShop.Carts
```

Implement simple cart item functions:

```text
list_cart_items/1
get_cart_item!/1
add_cart_item/3
update_cart_item_quantity/2
delete_cart_item/1
clear_cart/1
change_cart_item/2
```

Expected behavior:

* `list_cart_items/1` accepts a customer or customer id and returns that customer's cart items.
* `add_cart_item/3` accepts customer, product variant, and quantity.
* If a row for the same customer and product variant already exists, increment quantity instead of creating a duplicate row.
* `update_cart_item_quantity/2` rejects quantities below `1`.
* `clear_cart/1` deletes only that customer's cart items.
* Do not deduct stock when adding to cart.

## Tests

Add focused tests for:

* Cart item changeset required fields.
* Positive `quantity` constraint.
* Unique `customer_id` plus `product_variant_id` constraint.
* Foreign key constraints for customer and product variant.
* Adding the same product variant twice increments quantity.
* Clearing a cart deletes only that customer's items.

## Acceptance Criteria

* Migration creates the exact `cart_items` table and constraints.
* `cart_items` references `product_variant_id`, not `product_id`.
* `CaHeoShop.Carts.CartItem` compiles.
* `CaHeoShop.Carts` exposes the required functions.
* No cart seed data is added.
* `mix test` passes.
* `mix precommit` passes.
