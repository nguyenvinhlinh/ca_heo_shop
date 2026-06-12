# Database Model

## Overview

The database model is still in an early stage.

The currently implemented database only contains authentication-related application tables generated for Phoenix authentication. Business tables such as collections, products, carts, sale orders, recipients, and store settings are researched proposals unless implemented by a later task.

This document is the main database reference for future agents. It intentionally separates:

- implemented tables that exist in migrations and schemas
- proposed business tables summarized from research files
- deferred ideas that should not be implemented without a specific future task

Ignore `schema_migrations`; it is an Ecto system table, not an application table.

## Current Database Status

Current implemented application tables:

```text
users
users_tokens
```

Current migration source:

```text
priv/repo/migrations/20260606030215_create_users_auth_tables.exs
```

Current implemented application contexts:

```text
CaHeoShop.Accounts
```

No business-domain migrations, schemas, contexts, Repo queries, seeds, carts, checkout, order creation, recipients, or settings persistence are implemented yet.

## Implemented Tables

| Table          | Purpose                                                  | Schema module                  | Context module       |
|----------------|----------------------------------------------------------|--------------------------------|----------------------|
| `users`        | Registered user accounts and authentication credentials. | `CaHeoShop.Accounts.User`      | `CaHeoShop.Accounts` |
| `users_tokens` | Session, magic-link login, and email-change tokens.      | `CaHeoShop.Accounts.UserToken` | `CaHeoShop.Accounts` |


## Proposed Business Tables

| Table              | Proposed schema module                     | Proposed context module     | Purpose                                                                            | Source                                          |
|--------------------|--------------------------------------------|-----------------------------|------------------------------------------------------------------------------------|-------------------------------------------------|
| `collections`      | `CaHeoShop.Catalog.Collection`             | `CaHeoShop.Catalog`         | Storefront/admin product grouping and navigation entries.                          | `research/010_table-collections.md`             |
| `products`         | `CaHeoShop.Products.Product`               | `CaHeoShop.Products`        | Product identity, bilingual names/descriptions, slug, and collection relationship. | `research/011-table-products-product-images.md` |
| `product_variants` | `CaHeoShop.ProductVariants.ProductVariant` | `CaHeoShop.ProductVariants` | Sellable product options with price, cost, stock, image, and ordering.             | `research/011-table-products-product-images.md` |
| `product_images`   | `CaHeoShop.ProductImages.ProductImage`     | `CaHeoShop.ProductImages`   | Product-level gallery images.                                                      | `research/011-table-products-product-images.md` |
| `cart_items`       | `CaHeoShop.Carts.CartItem`                 | `CaHeoShop.Carts`           | Active authenticated customer cart line items.                                     | `research/012-table-cart-items.md`                   |
| `sale_orders`      | `CaHeoShop.Sales.SaleOrder`                | `CaHeoShop.Sales`           | Order header, customer/recipient snapshots, statuses, payment, totals.             | `research/013_table-sale-orders.md`             |
| `sale_order_items` | `CaHeoShop.Sales.SaleOrderItem`            | `CaHeoShop.Sales`           | Order line items with selected variant reference and historical snapshots.         | `research/013_table-sale-orders.md`             |
| `recipients`       | `CaHeoShop.Customers.Recipient`            | `CaHeoShop.Customers`       | Customer saved delivery recipients/addresses.                                      | `research/014_table-recipients.md`              |
| `store_settings`   | `CaHeoShop.StoreSettings.StoreSetting`     | `CaHeoShop.StoreSettings`   | Single-row global contact, shipping, and payment display settings.                 | `research/015_table-store-settings.md`          |


## Table Summary

| Table              | Status      | Purpose                                         | Related Research                                |
|--------------------|-------------|-------------------------------------------------|-------------------------------------------------|
| `users`            | Implemented | Authentication account identity.                | Existing migration/schema                       |
| `users_tokens`     | Implemented | Authentication token storage.                   | Existing migration/schema                       |
| `collections`      | Proposed    | Catalog grouping and storefront navigation.     | `research/010_table-collections.md`             |
| `products`         | Proposed    | Product identity and bilingual product content. | `research/011-table-products-product-images.md` |
| `product_variants` | Proposed    | Sellable variant price/cost/stock/image.        | `research/011-table-products-product-images.md` |
| `product_images`   | Proposed    | Product gallery images.                         | `research/011-table-products-product-images.md` |
| `cart_items`       | Proposed    | Active customer cart line items.                | `research/012-table-cart-items.md`              |
| `sale_orders`      | Proposed    | Sale order headers and order snapshots.         | `research/013_table-sale-orders.md`             |
| `sale_order_items` | Proposed    | Sale order line items.                          | `research/013_table-sale-orders.md`             |
| `recipients`       | Proposed    | Saved customer delivery recipients.             | `research/014_table-recipients.md`              |
| `store_settings`   | Proposed    | Single global store settings row.               | `research/015_table-store-settings.md`          |


## Relationships Overview

Implemented relationships:

- `User has many UserTokens`
- `UserToken belongs to User`

Proposed catalog relationships:

- `Product belongs to Collection` through `products.collection_id`
- `Product has many ProductVariants`
- `ProductVariant belongs to Product`
- `Product has many ProductImages`
- `ProductImage belongs to Product`

Proposed cart relationships:

- `CartItem belongs to customer` through `cart_items.customer_id -> users.id`
- `CartItem belongs to ProductVariant` through `cart_items.product_variant_id`
- Cart rows should reference `product_variant_id`, not `product_id`, because price, cost, stock, image, and selected option are variant-level.

Proposed sales relationships:

- `SaleOrder belongs to customer` through `sale_orders.customer_id -> users.id`
- `SaleOrder has many SaleOrderItems`
- `SaleOrderItem belongs to SaleOrder`
- `SaleOrderItem belongs to ProductVariant`
- Sale order items should snapshot product name, product slug, variant name, unit price, production cost, line total, and image filename.

Proposed customer recipient relationships:

- `Recipient belongs to customer` through `recipients.customer_id -> users.id`
- `User/Customer has many Recipients`
- Sale orders should snapshot recipient information at order time. A future optional `sale_orders.recipient_id` can be added as provenance after checkout supports selecting saved recipients.

## Authentication Tables

### `users`

Status: implemented.

Related modules:

```text
Schema:  CaHeoShop.Accounts.User
Context: CaHeoShop.Accounts
Scope:   CaHeoShop.Accounts.Scope
```

Fields:

| Field             | Type                                      | Required | Notes                                                         |
|-------------------|-------------------------------------------|----------|---------------------------------------------------------------|
| `id`              | primary key                               | yes      | Generated by Ecto/database.                                   |
| `email`           | `citext` in database, `:string` in schema | yes      | Case-insensitive email identity.                              |
| `hashed_password` | `string`                                  | no       | Password hash when password auth is used. Redacted in schema. |
| `confirmed_at`    | `utc_datetime`                            | no       | Email confirmation timestamp.                                 |
| `inserted_at`     | `utc_datetime`                            | yes      | Generated by Ecto timestamps.                                 |
| `updated_at`      | `utc_datetime`                            | yes      | Generated by Ecto timestamps.                                 |


Virtual schema fields:

| Field              | Type                         | Purpose                                                    |
|--------------------|------------------------------|------------------------------------------------------------|
| `password`         | `:string`, virtual, redacted | Registration/password changes before hashing.              |
| `authenticated_at` | `:utc_datetime`, virtual     | Recent authentication/sudo-mode state from session tokens. |


Indexes and constraints:

```elixir
create unique_index(:users, [:email])
```

### `users_tokens`

Status: implemented.

Related modules:

```text
Schema:  CaHeoShop.Accounts.UserToken
Context: CaHeoShop.Accounts
```

Fields:

| Field              | Type                      | Required | Notes                                                          |
|--------------------|---------------------------|----------|----------------------------------------------------------------|
| `id`               | primary key               | yes      | Generated by Ecto/database.                                    |
| `user_id`          | foreign key to `users.id` | yes      | Deletes with the user.                                         |
| `token`            | `binary`                  | yes      | Raw session token or hashed email token, depending on context. |
| `context`          | `string`                  | yes      | Token purpose such as `session`, `login`, or `change:<email>`. |
| `sent_to`          | `string`                  | no       | Email address used for email-token flows.                      |
| `authenticated_at` | `utc_datetime`            | no       | Session/sudo-mode authentication timestamp.                    |
| `inserted_at`      | `utc_datetime`            | yes      | Generated by Ecto timestamps.                                  |


There is no `updated_at` column on `users_tokens`.

Indexes and constraints:

```elixir
create index(:users_tokens, [:user_id])
create unique_index(:users_tokens, [:context, :token])
```

## Catalog Tables

### `collections`

Status: proposed.

Core fields:

```text
id
name_vi
name_en
slug
description_vi
description_en
image_filename
nav_display_order
inserted_at
updated_at
```

Important decisions:

- `name_vi` is required and is the primary Vietnamese display name.
- `name_en` is optional and can support English display and slug generation.
- `slug` is required and unique.
- `nav_display_order` is nullable; values start from `0` when present.
- `nav_display_order = NULL` means the collection should not appear in header navigation.
- The collection schema does not need to load belonging products directly; product-side queries can filter by `products.collection_id`.
- `products.collection_id` should use `on_delete: :restrict`.

Important constraints:

```elixir
create unique_index(:collections, [:slug])
create index(:collections, [:nav_display_order])
create constraint(:collections, :nav_display_order_non_negative,
         check: "nav_display_order IS NULL OR nav_display_order >= 0")
```

### `products`

Status: proposed.

Core fields:

```text
id
collection_id
slug
name_vi
name_en
description_vi
description_en
inserted_at
updated_at
```

Important decisions:

- A product belongs to one collection.
- `slug` is required and unique.
- Product names and descriptions are bilingual: `name_vi`, `name_en`, `description_vi`, `description_en`.
- Do not keep generic `name`, `description`, or `description_markdown` columns in the first proposal.
- Product-level `selling_price`, `production_cost`, and `stock_quantity` are not proposed; those live on variants.

Important constraints:

```elixir
create unique_index(:products, [:slug])
create index(:products, [:collection_id])
```

### `product_variants`

Status: proposed.

Core fields:

```text
id
product_id
variant_name
production_cost
selling_price
stock_quantity
image_filename
display_order
inserted_at
updated_at
```

Important decisions:

- Product variants are the sellable options.
- `variant_name` is a simple combined human-readable value such as `PLA Red`.
- `production_cost`, `selling_price`, and `stock_quantity` live at the variant level.
- Prices and costs are integer VND.
- `display_order` is product-local ordering and defaults to `0`.
- `image_filename` is an optional variant-specific preview image.

Important constraints:

```elixir
create index(:product_variants, [:product_id])
create index(:product_variants, [:product_id, :display_order])
create unique_index(:product_variants, [:product_id, :variant_name])
create constraint(:product_variants, :production_cost_non_negative,
         check: "production_cost >= 0")
create constraint(:product_variants, :selling_price_non_negative,
         check: "selling_price >= 0")
create constraint(:product_variants, :stock_quantity_non_negative,
         check: "stock_quantity >= 0")
create constraint(:product_variants, :variant_display_order_non_negative,
         check: "display_order >= 0")
```

### `product_images`

Status: proposed.

Core fields:

```text
id
product_id
filename
display_order
inserted_at
updated_at
```

Important decisions:

- Product images are general product gallery images.
- Variant-specific representative images belong on `product_variants.image_filename`.
- `display_order` defaults to `0` and determines gallery order.

Important constraints:

```elixir
create index(:product_images, [:product_id])
create index(:product_images, [:product_id, :display_order])
create constraint(:product_images, :image_display_order_non_negative,
         check: "display_order >= 0")
```

## Cart Tables

### `cart_items`

Status: proposed.

Core fields:

```text
id
customer_id
product_variant_id
quantity
inserted_at
updated_at
```

Important decisions:

- `cart_items` is a line-item table where each row is one selected variant in one customer's active cart.
- `customer_id` references `users.id`.
- `product_variant_id` references `product_variants.id`.
- `product_id` is not enough because it cannot determine selected variant price, production cost, stock, image, or option label.
- The unique cart identity is `customer_id + product_variant_id`.
- Quantity must be greater than `0`; removing an item should delete the row.

Important constraints:

```elixir
create index(:cart_items, [:customer_id])
create index(:cart_items, [:product_variant_id])
create unique_index(:cart_items, [:customer_id, :product_variant_id])
create constraint(:cart_items, :quantity_positive, check: "quantity > 0")
```

Deferred cart ideas:

- Cart header/status lifecycle
- Guest carts with session IDs
- Cart expiration and merge-on-login behavior

## Sales / Order Tables

### `sale_orders`

Status: proposed.

Core fields:

```text
id
order_number
customer_id
status
payment_status
fulfillment_status
subtotal_amount
shipping_fee
discount_amount
total_amount
customer_name
customer_email
customer_phone
recipient_fullname
recipient_phone_number
recipient_address
payment_method
payment_reference
customer_note
admin_note
confirmed_at
cancelled_at
completed_at
inserted_at
updated_at
```

Important decisions:

- `order_number` is required and unique for customer/admin display.
- `customer_id` references `users.id`.
- Customer contact fields are snapshots because account data may change.
- Recipient fields are snapshots because saved recipients may change or be deleted.
- Statuses are strings in the first proposal; no enum type or state machine yet.
- Money fields are integer VND and non-negative.

Important constraints:

```elixir
create unique_index(:sale_orders, [:order_number])
create index(:sale_orders, [:customer_id])
create index(:sale_orders, [:status])
create index(:sale_orders, [:payment_status])
create index(:sale_orders, [:fulfillment_status])
create index(:sale_orders, [:inserted_at])
```

### `sale_order_items`

Status: proposed.

Core fields:

```text
id
sale_order_id
product_variant_id
product_name_snapshot
product_slug_snapshot
variant_name_snapshot
unit_price_snapshot
production_cost_snapshot
quantity
line_total_amount
image_filename_snapshot
inserted_at
updated_at
```

Important decisions:

- `sale_order_items.product_variant_id` references the selected sellable variant.
- Do not use only `product_id`; it cannot determine selected price, cost, stock, image, or option.
- Snapshot product and variant display/money fields at checkout time.
- `line_total_amount` should be `unit_price_snapshot * quantity`.
- `production_cost_snapshot` supports later profit reporting.

Important constraints:

```elixir
create index(:sale_order_items, [:sale_order_id])
create index(:sale_order_items, [:product_variant_id])
create constraint(:sale_order_items, :quantity_positive, check: "quantity > 0")
create constraint(:sale_order_items, :unit_price_snapshot_non_negative,
         check: "unit_price_snapshot >= 0")
create constraint(:sale_order_items, :production_cost_snapshot_non_negative,
         check: "production_cost_snapshot >= 0")
create constraint(:sale_order_items, :line_total_amount_non_negative,
         check: "line_total_amount >= 0")
```

Cart-to-order concept:

- Create one `sale_orders` header.
- Convert each cart row into one `sale_order_items` row.
- Copy current variant price/cost and product/variant display values into snapshots.
- Calculate order totals from copied order item values.
- Delete cart rows after successful order creation.

## Customer Recipient Tables

### `recipients`

Status: proposed.

Core fields:

```text
id
customer_id
name
address
phone_number
is_default
inserted_at
updated_at
```

Important decisions:

- Use the correctly spelled table name `recipients`.
- Column names intentionally do not repeat `recipient`; use `name`, `address`, `phone_number`, and `is_default`.
- `customer_id` references `users.id`.
- Use one text `address` field first; structured address fields are deferred.
- `is_default` defaults to `false`.
- A partial unique index allows each customer to have at most one default recipient.
- Sale orders still snapshot recipient fields at order creation.

Important constraints:

```elixir
create index(:recipients, [:customer_id])
create unique_index(:recipients, [:customer_id],
         where: "is_default = true",
         name: :recipients_one_default_per_customer_index)
```

## Store Settings Tables

### `store_settings`

Status: proposed.

Core fields:

```text
id
singleton_key
contact_email
contact_phone
payment_note
shipping_note
inserted_at
updated_at
```

Important decisions:

- Use a single-row explicit-column table.
- Do not use a key-value settings table in the first implementation.
- `singleton_key` is a boolean fixed to `true` to enforce one row.
- `contact_email` and `contact_phone` support manual support/order coordination.
- `payment_note` and `shipping_note` support checkout/cart display.
- Store identity, QR, bank account, announcements, and shipping fee fields are deferred.

Important constraints:

```elixir
create unique_index(:store_settings, [:singleton_key])
create constraint(:store_settings, :singleton_key_true, check: "singleton_key = true")
```

## Deferred / Future Tables

Do not implement these without a future task:

| Deferred table/idea | Reason |
| --- | --- |
| Cart header table | Current cart proposal uses `cart_items` as line items. Needed only for guest carts, abandoned carts, or lifecycle state. |
| `inventory_movements` | Current variant model stores simple stock count only. Movement history is not designed. |
| `payments` | Current order/settings research only stores payment notes and statuses, not payment transactions. |
| `sale_order_status_logs` or order events | Audit/status history is deferred. |
| `product_variant_images` | Current proposal uses one variant `image_filename` plus product gallery images. |
| `product_bundle_items` | Product bundles are not researched. |
| `media_assets` | Current image fields store filenames/asset keys directly. |
| Structured recipient address tables/fields | One text `address` field is enough for the first recipients proposal. |
| Key-value settings | Explicit single-row `store_settings` is preferred now. |

## Research References

- `research/010_table-collections.md`
- `research/011-table-products-product-images.md`
- `research/012-table-cart-items.md`
- `research/013_table-sale-orders.md`
- `research/014_table-recipients.md`
- `research/015_table-store-settings.md`

All expected database research files for tasks 006 through 012 are present at the time of this consolidation.

## Open Questions

- Should the proposed `collections` module/context naming stay under `Catalog`, or be renamed to `Collections` to match the separate product contexts?
- Should real checkout require authentication before carts, recipients, and sale orders are implemented?
- Should `sale_orders` eventually include optional `recipient_id` as provenance in addition to recipient snapshots?
- Should product and variant records be archived instead of deleted once order items reference them?
- Should `store_settings` be seeded during deployment or created lazily by the context?
- Should future admin authorization require roles or permissions on `users` before business CRUD is implemented?
