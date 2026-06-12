# Task 009: Research Carts Database Schema

## Objective

Research the current storefront, cart, checkout, user/authentication model, and product model, then propose a database schema for the shopping cart.

The expected output is a research document:

```text
research/012-table-cart-items.md
```

This task is for research and database design proposal only.

Do not create migrations, Ecto schemas, Ecto contexts, or real cart behavior in this task.

---

## Deliverable

Create the following file:

```text
research/012-table-cart-items.md
```

The document should describe the proposed database schema for `cart_items` based on:

* Current cart UI
* Current checkout UI
* Existing user/authentication tables
* Product schema research
* Expected ecommerce behavior for Ca Heo DIY

---

## Required Reading

Before starting, read:

```text
AGENTS.md
agents/001_phoenix-agent.md
agents/010_business-context.md
agents/011_architecture.md
agents/012_database-model.md
agents/013_ui-system.md
agents/014_task-workflow.md
research/004-commerce-order-flow.md
tasks/004-build-storefront-skeleton.md
tasks/007-research-current-database-model.md
```

Also read these research files if they exist:

```text
research/010_table-collections.md
research/011-table-products-product-images.md
```

Use `research/004-commerce-order-flow.md` as the primary source for cart procedure requirements:

```text
cart_items are active selected variant rows
cart_items reference customer_id, product_variant_id, quantity
cart items are cleared only after sale order, sale order items, fulfillment procedure, and payment procedure are created successfully
cart conversion stages are not persistent cart statuses
```

Inspect current code related to:

```text
/cart
/checkout
/products
/products/:slug
/account
/orders
lib/**/accounts
priv/repo/migrations
```

If some routes, files, or research documents do not exist yet, document that clearly.

---

## Core Rule

This is a research task only.

Do not create, modify, or run:

* Database migrations
* Ecto schemas
* Ecto contexts
* Repo queries
* Seeds
* Tests
* Real cart persistence
* Real checkout behavior
* Real order creation

The goal is to produce a database design proposal that can be reviewed before implementation.

---

## Known Requirements

The proposed cart schema must support these initial fields:

```text
customer_id
product_variant_id
quantity
```

These requirements are intentionally minimal. `product_variant_id` is required because a product alone is not enough to determine price, cost, stock, or selected option.

During research, if additional fields appear necessary, propose them clearly and explain why.

Do not add fields blindly.

---

## Relationship Requirements

### Customer Relationship

Each cart row should belong to one customer.

Expected field:

```text
customer_id
```

Research and document whether `customer_id` should reference:

```text
users.id
```

or whether a separate future `customers` table is needed.

For the first implementation, prefer the simplest approach that fits the current authentication model.

The research document should explain:

* Whether current users represent customers
* Whether `customer_id` should be named `user_id` instead
* Tradeoffs between `customer_id` and `user_id`
* Whether guest carts should be deferred

---

### Product Relationship

Each cart row should belong to one selected product variant.

Expected field:

```text
product_variant_id
```

Research and document:

* How this relates to the proposed `product_variants` table
* Why `product_id` is not enough to determine price
* Whether the variant price should be copied into cart or read from product variant
* Whether product or variant deletion should restrict, nullify, or delete related cart rows

For the first implementation, prefer simple cart behavior.

---

### Quantity

Each cart row must store product quantity.

Expected field:

```text
quantity
```

Research and document:

* Field type
* Default value
* Minimum allowed value
* Whether zero quantity should be allowed
* Whether quantity should be limited by stock quantity

Do not implement inventory validation in this task.

---

## Important Schema Question

Research whether the project should use:

```text
Option A:
A single cart_items table where each row represents one selected product variant in one customer's cart.

Option B:
A carts table representing the cart header, plus a cart_items table representing products in the cart.
```

Example Option A:

```text
cart_items
- id
- customer_id
- product_variant_id
- quantity
- inserted_at
- updated_at
```

Example Option B:

```text
carts
- id
- customer_id
- status
- inserted_at
- updated_at

cart_items
- id
- cart_id
- product_variant_id
- quantity
- inserted_at
- updated_at
```

The current requirement uses the table name:

```text
cart_items
```

with:

```text
customer_id
product_variant_id
quantity
```

So the research document should evaluate whether this means:

```text
cart_items as cart line items
```

or whether a separate `carts` header table should be introduced later.

For the first implementation, recommend the simplest schema that supports the current UI.

---

## Areas To Research

### Storefront Cart Usage

Inspect the cart page.

Research:

* What data the cart page displays
* Whether cart item quantity can be changed
* Whether subtotal is shown
* Whether product image, name, slug, price, or availability is needed
* Whether cart supports removing items
* Whether cart state is currently mock data only

Document what fields the cart UI needs.

---

### Checkout Usage

Inspect the checkout page.

Research:

* What data checkout needs from cart
* Whether checkout reads cart items directly
* Whether checkout requires customer information
* Whether checkout creates an order yet
* Whether shipping/payment fields affect the cart schema

Do not design the full orders schema in this task.

Only document cart-related needs.

---

### Authentication and Customer Model

Inspect the existing authentication model.

Research:

* Existing users table
* Existing user schema
* Whether users are customers
* Whether buyer/customer role exists
* Whether guest checkout exists or should be deferred

Document whether `customer_id` should reference `users.id` for now.

---

### Product Model Dependency

Inspect product mock data and product research.

Research:

* Whether products have stable IDs yet
* Whether product slugs are used in cart UI
* Why cart should store `product_variant_id`
* Whether product image and product name should be read through product variant/product associations
* Whether price should be read from product variant or snapshotted later in order items

Cart should usually stay simple. Order pricing snapshots should be handled in a future orders schema.

---

## Proposed Schema Content

The research document should propose a first version of the cart schema.

At minimum, evaluate these fields:

```text
id
customer_id
product_variant_id
quantity
inserted_at
updated_at
```

Also evaluate whether these fields are needed now or later:

```text
status
session_id
cart_id
cart_item_id
unit_price_snapshot
currency
expires_at
metadata
```

Separate required fields from optional or deferred fields.

---

## Indexes and Constraints

The research document should recommend database constraints and indexes.

Evaluate:

```text
foreign key from cart_items.customer_id to users.id
foreign key from cart_items.product_variant_id to product_variants.id
unique index on customer_id + product_variant_id
index on customer_id
index on product_variant_id
not null constraints
quantity positive constraint
```

Also document tradeoffs.

The research document should explain why a unique index on:

```text
customer_id + product_id
```

is not enough when products have variants. The research document should explain why a unique index on:

```text
customer_id + product_variant_id
```

is useful to prevent duplicate cart rows for the same selected product variant.

---

## Naming Recommendation

Recommend final naming for:

```text
Table name
Schema module
Context module
Relationship fields
Route usage
```

Examples to evaluate:

```text
cart_items
CaHeoShop.Carts.CartItem
CaHeoShop.Carts
customer_id
product_variant_id
```

Also evaluate whether this would be better as:

```text
cart_items
CaHeoShop.Carts.CartItem
```

or under a broader commerce context later.

Do not implement naming changes in this task.

---

## Expected Output Structure

The file `research/012-table-cart-items.md` should contain:

1. Overview
2. Current UI Findings
3. Current Authentication and Customer Model
4. Product Relationship Analysis
5. Cart Schema Design Options
6. Proposed `cart_items` Table
7. Field-by-Field Explanation
8. Indexes and Constraints
9. Recommended Ecto Schema Shape
10. Recommended Migration Shape
11. Optional or Deferred Fields
12. Open Questions
13. Final Recommendation

---

## Recommended Migration Shape

The research document may include a sample migration shape as documentation only.

Do not create the actual migration file.

Example format:

```elixir
create table(:cart_items) do
  add :customer_id, references(:users, on_delete: :delete_all), null: false
  add :product_variant_id, references(:product_variants, on_delete: :restrict), null: false
  add :quantity, :integer, null: false, default: 1

  timestamps(type: :utc_datetime)
end

create index(:cart_items, [:customer_id])
create index(:cart_items, [:product_variant_id])
create unique_index(:cart_items, [:customer_id, :product_variant_id])
```

If research recommends `user_id` instead of `customer_id`, document that clearly.

If research recommends a `carts` header table plus `cart_items` instead of a single `cart_items` table, provide the alternative sample migration shape as a proposal only.

These samples should be treated as proposals, not implementation.

---

## Research Guidance

During research, if additional fields appear necessary from the UI or business workflow, add them to the proposal.

However:

* Do not add fields just because ecommerce platforms usually have them.
* Keep the first implementation simple.
* Clearly separate required fields from deferred fields.
* Explain why each extra field is recommended.
* Do not design full orders, payments, shipping, or inventory systems in this task.

---

## Success Criteria

The task is complete when:

* `research/012-table-cart-items.md` is created.
* The document is based on current UI and mock data observations.
* The known cart requirements are addressed.
* The relationship between cart, customer, and product is clearly explained.
* The document evaluates whether `customer_id` should reference `users.id`.
* The document evaluates whether `cart_items` should be a line-item table or whether a separate `carts` header table should exist later.
* Required fields are identified.
* Optional or deferred fields are separated from required fields.
* Indexes and constraints are recommended.
* Open questions are documented.
* No database migration is created.
* No Ecto schema is created.
* No Ecto context is created.
* No Repo queries are added.
* No real cart behavior is implemented.
* No production code is changed unless needed only to inspect references.
