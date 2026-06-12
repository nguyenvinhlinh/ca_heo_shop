# Carts Table Research

## 1. Overview

This document proposes the first database shape for shopping carts.

The current storefront has `/cart` and `/checkout` pages, but both are mock-only. There is no real cart persistence, checkout persistence, payment behavior, or order creation yet.

This task is research only. The examples below are proposals, not implemented migrations, Ecto schemas, contexts, Repo queries, seeds, tests, cart persistence, checkout behavior, or order creation.

## 2. Current UI Findings

Current relevant routes:

- `/cart`
- `/checkout`
- `/products`
- `/products/:slug`
- `/account`
- `/orders`

Route placement:

- Storefront routes are inside the existing `:current_user` LiveView session and `:browser` pipeline because they work with or without authentication.
- Authentication uses `CaHeoShop.Accounts`, `CaHeoShop.Accounts.User`, `CaHeoShop.Accounts.UserToken`, and `CaHeoShop.Accounts.Scope`.

Current cart page:

- receives mock `cart_items`
- renders product image
- renders product name
- renders product price
- renders quantity
- shows static `-` and `+` controls
- calculates subtotal from `product.price_cents * quantity`
- links to `/checkout`
- does not remove items
- does not persist quantity changes
- does not validate stock

Current checkout page:

- receives the same mock `cart_items`
- renders customer information fields
- renders shipping address fields
- renders an order note field
- renders a payment placeholder
- renders an order summary with product image, product name, quantity, and subtotal
- does not submit real checkout data
- does not create orders

Current mock cart items are built from the first two mock products:

```text
%{product: product, quantity: quantity}
```

There are no stable product database IDs yet because the products table has not been implemented.

## 3. Current Authentication and Customer Model

Current application tables:

```text
users
users_tokens
```

Current user schema:

```text
CaHeoShop.Accounts.User
```

Current context:

```text
CaHeoShop.Accounts
```

There is no separate `customers` table yet. The current `users` table represents authenticated users and is the only persisted buyer identity available.

Recommended first relationship:

```text
carts.customer_id -> users.id
```

Use the column name `customer_id` because it describes the role of the user in the ecommerce workflow. In Ecto this can still point to `CaHeoShop.Accounts.User`:

```elixir
belongs_to :customer, CaHeoShop.Accounts.User, foreign_key: :customer_id
```

Tradeoff:

- `user_id` is technically clearer because it references `users.id`.
- `customer_id` is business clearer because the cart belongs to the buyer/customer.

For the first implementation, prefer `customer_id` referencing `users.id` because it matches the task requirement and avoids creating a separate customer table before the project needs one.

Guest carts should be deferred. Supporting guest carts would require `session_id`, expiration, merge-on-login behavior, and more lifecycle rules than the current mock UI needs.

## 4. Product Relationship Analysis

Current product persistence does not exist yet. Product research in `research/011-table-products-product-images.md` proposes:

```text
products
product_variants
product_images
```

That research recommends variants as sellable options. Cart rows should reference `product_variant_id` because price, production cost, stock, variant image, and the selected option are variant-level concerns.

Task 009's minimal required cart fields are:

```text
customer_id
product_variant_id
quantity
```

For the first cart table proposal in this document, use `product_variant_id`. The current mock UI points each cart row to a product-like map, but the persistent schema should point to the selected sellable option, not only the parent product.

Important rule:

- `product_id` is not enough to determine price because a product can have multiple variants with different selling prices, production costs, stock quantities, and images.
- `product_variant_id` identifies the actual selected sellable option.
- Product name and slug can be read through the variant's product association.

Product image, name, slug, and current display price should normally be read through product variant/product associations, not copied into the cart. Price snapshots belong in future sale order items, not the active cart.

Variant deletion should be restricted while cart rows reference the variant. Deleting active cart rows automatically could surprise users, while nullifying variant references would create invalid cart rows.

## 5. Cart Schema Design Options

### Option A: `carts` as line items

Each row is one selected product variant in one customer's cart:

```text
carts
- id
- customer_id
- product_variant_id
- quantity
- inserted_at
- updated_at
```

Benefits:

- simplest possible shape
- matches the required customer, variant, and quantity fields
- fits current UI
- no cart header lifecycle yet
- avoids unused status/session fields

Tradeoffs:

- table name `carts` represents cart lines rather than a cart header
- adding guest carts or abandoned cart lifecycle later may require a separate cart header or migration
- cannot store cart-wide fields such as status, currency, or expiration cleanly

### Option B: `carts` header plus `cart_items`

Cart header:

```text
carts
- id
- customer_id
- status
- inserted_at
- updated_at
```

Cart line items:

```text
cart_items
- id
- cart_id
- product_variant_id
- quantity
- inserted_at
- updated_at
```

Benefits:

- more explicit domain model
- better for guest carts, cart status, expiration, merge behavior, and cart-to-order conversion
- avoids overloading `carts` as line items

Tradeoffs:

- more tables and more workflow decisions
- not needed by current mock UI
- beyond the task's minimal `customer_id`, `product_variant_id`, `quantity` requirement

### Recommendation

For the first implementation, use Option A: a single `carts` table where each row is a customer's cart line item.

Defer a separate `cart_items` table until the app needs guest carts, cart headers, abandoned cart tracking, cart status, or checkout lifecycle state.

## 6. Proposed `carts` Table

Recommended first fields:

```text
id
customer_id
product_variant_id
quantity
inserted_at
updated_at
```

Recommended first table meaning:

```text
carts = active cart line items
```

Each customer/product variant pair should have at most one row. Updating quantity should update the existing row.

## 7. Field-by-Field Explanation

### `id`

- Type: primary key
- Required: yes
- Default: generated by database
- Needed now: yes
- Purpose: stable cart row identity

### `customer_id`

- Type: foreign key to `users.id`
- Required: yes
- Default: none
- Needed now: yes
- Purpose: owner of the cart row

Recommended relationship:

```text
carts.customer_id -> users.id
```

Use `customer_id` in the cart schema while documenting that it references the existing `users` table.

### `product_variant_id`

- Type: foreign key to `product_variants.id`
- Required: yes
- Default: none
- Needed now: yes
- Purpose: selected sellable product option in the cart row

Do not use only `product_id` for persisted carts. It cannot determine variant-specific selling price, production cost, stock quantity, image, or option name. The product can be reached through the selected variant when the UI needs product-level name, slug, or collection data.

### `quantity`

- Type: integer
- Required: yes
- Default: `1`
- Needed now: yes
- Purpose: number of units for this cart row

Recommended rules:

- minimum value is `1`
- zero quantity should not be allowed
- deleting/removing an item should delete the cart row
- negative quantity should not be allowed
- future cart updates should validate requested quantity against available stock

Do not implement inventory validation in this task.

### `inserted_at`

- Type: UTC datetime timestamp
- Required: yes
- Default: generated by Ecto timestamps
- Needed now: yes
- Purpose: track when the cart row was created

### `updated_at`

- Type: UTC datetime timestamp
- Required: yes
- Default: generated by Ecto timestamps
- Needed now: yes
- Purpose: track quantity changes or product changes on the cart row

## 8. Indexes and Constraints

Recommended constraints:

- `customer_id` not null
- `product_variant_id` not null
- `quantity` not null
- `quantity > 0`

Recommended foreign keys:

```text
carts.customer_id -> users.id
carts.product_variant_id -> product_variants.id
```

Recommended delete behavior:

- `customer_id`: `on_delete: :delete_all`
- `product_variant_id`: `on_delete: :restrict`

Recommended indexes:

```elixir
create index(:carts, [:customer_id])
create index(:carts, [:product_variant_id])
create unique_index(:carts, [:customer_id, :product_variant_id])
```

The unique index on `customer_id, product_variant_id` prevents duplicate cart rows for the same customer's same selected variant. Instead of inserting duplicates, the cart context should update the existing row quantity.

Recommended check constraint:

```elixir
create constraint(:carts, :quantity_positive, check: "quantity > 0")
```

Rejected alternative:

A uniqueness rule around the parent product:

```text
customer_id + product_id
```

is not enough when the same product can be added with different variants. The correct uniqueness rule is:

```text
customer_id + product_variant_id
```

## 9. Recommended Ecto Schema Shape

Documentation-only example:

```elixir
schema "carts" do
  belongs_to :customer, CaHeoShop.Accounts.User, foreign_key: :customer_id
  belongs_to :product_variant, CaHeoShop.ProductVariants.ProductVariant

  field :quantity, :integer, default: 1

  timestamps(type: :utc_datetime)
end
```

Recommended naming:

```text
Table name: carts
Schema module: CaHeoShop.Carts.Cart
Context module: CaHeoShop.Carts
Relationship fields:
  customer_id
  product_variant_id
```

The context should own cart row CRUD and quantity update behavior when implemented later.

## 10. Recommended Migration Shape

Documentation-only example:

```elixir
create table(:carts) do
  add :customer_id, references(:users, on_delete: :delete_all), null: false
  add :product_variant_id, references(:product_variants, on_delete: :restrict), null: false
  add :quantity, :integer, null: false, default: 1

  timestamps(type: :utc_datetime)
end

create index(:carts, [:customer_id])
create index(:carts, [:product_variant_id])
create unique_index(:carts, [:customer_id, :product_variant_id])

create constraint(:carts, :quantity_positive, check: "quantity > 0")
```

Do not store both `product_id` and `product_variant_id` unless there is a clear denormalization reason. The selected variant already points back to its product.

## 11. Optional or Deferred Fields

### `status`

Defer. A status field belongs better on a cart header model, not on line-item-only `carts`.

### `session_id`

Defer. Needed for guest carts, but guest carts are not part of the first implementation.

### `cart_id`

Defer. Needed only if the project introduces a cart header plus `cart_items`.

### `cart_item_id`

Do not add. The proposed `carts` row already acts as the cart item.

### `unit_price_snapshot`

Defer. Active carts should read current pricing from product variants. Price snapshots belong in future sale order items so completed orders remain historically accurate.

### `currency`

Defer. The current project prices are VND-focused. If multiple currencies are introduced later, currency should be considered with product pricing and order snapshots.

### `expires_at`

Defer. Useful for guest or abandoned carts, but not required for authenticated simple carts.

### `metadata`

Defer. Do not add a metadata blob without a concrete workflow.

## 12. Open Questions

- Should the first cart table use `customer_id` or `user_id` as the column name?
- Should removing an item delete the row, or should quantity `0` ever be stored? This proposal recommends deleting the row.
- Should cart rows be automatically cleared after checkout order creation?
- Should guest carts be supported later, and if so should they use a cart header table?
- Should variant deletion be blocked while active cart rows reference the variant?

## 13. Final Recommendation

For the first implementation, create a simple `carts` table where each row is one active cart line item:

```text
carts
- customer_id
- product_variant_id
- quantity
```

Recommended table and modules:

```text
Table name: carts
Schema module: CaHeoShop.Carts.Cart
Context module: CaHeoShop.Carts
```

Recommended relationships:

```text
carts.customer_id -> users.id
carts.product_variant_id -> product_variants.id
```

Recommended constraints:

```text
customer_id not null
product_variant_id not null
quantity not null, default 1
quantity > 0
unique customer_id + product_variant_id
```

This keeps the first cart implementation aligned with the required customer, selected variant, and quantity data. `product_id` should not be used as the cart's sellable item reference because it cannot determine variant-specific price.
