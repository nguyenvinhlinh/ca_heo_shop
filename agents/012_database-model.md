# Database Model

## Overview

The database model is still early. The implemented application database currently contains only Phoenix authentication tables.

Business tables are research proposals unless a later implementation task creates migrations, schemas, contexts, and real behavior.

Ignore `schema_migrations`; it is an Ecto system table, not an application table.

## Current Implemented Tables

Current migration source:

```text
priv/repo/migrations/20260606030215_create_users_auth_tables.exs
```

Implemented application tables:

```text
users
users_tokens
```

Implemented context:

```text
CaHeoShop.Accounts
```

No business-domain migrations, schemas, contexts, Repo queries, seeds, cart persistence, checkout, order creation, fulfillment, payment, returns, recipients, settings persistence, financial ledger, or inventory movement behavior are implemented yet.

## Implemented Table Summary

| Table          | Purpose                                                  | Schema module                  | Context module       |
|----------------|----------------------------------------------------------|--------------------------------|----------------------|
| `users`        | Registered user accounts and authentication credentials. | `CaHeoShop.Accounts.User`      | `CaHeoShop.Accounts` |
| `users_tokens` | Session, login, and email-change token storage.          | `CaHeoShop.Accounts.UserToken` | `CaHeoShop.Accounts` |

## Proposed Business Tables

| Table                    | Proposed schema module                                      | Proposed context module             | Purpose                                                        | Source                                                        |
|--------------------------|-------------------------------------------------------------|-------------------------------------|----------------------------------------------------------------|---------------------------------------------------------------|
| `collections`            | `CaHeoShop.Catalog.Collection`                              | `CaHeoShop.Catalog`                 | Catalog grouping and storefront navigation.                    | `research/010_table-collections.md`                           |
| `products`               | `CaHeoShop.Products.Product`                                | `CaHeoShop.Products`                | Product identity, bilingual content, slug, collection link.    | `research/011-table-products-product-images.md`               |
| `product_variants`       | `CaHeoShop.ProductVariants.ProductVariant`                  | `CaHeoShop.ProductVariants`         | Sellable product options with price, cost, stock, image.       | `research/011-table-products-product-images.md`               |
| `product_images`         | `CaHeoShop.ProductImages.ProductImage`                      | `CaHeoShop.ProductImages`           | Product-level gallery images.                                  | `research/011-table-products-product-images.md`               |
| `cart_items`             | `CaHeoShop.Carts.CartItem`                                  | `CaHeoShop.Carts`                   | Active authenticated customer cart line items.                 | `research/012-table-cart-items.md`                            |
| `sale_orders`            | `CaHeoShop.Sales.SaleOrder`                                 | `CaHeoShop.Sales`                   | Order header, customer/recipient snapshots, totals, notes.     | `research/013_table-sale-orders.md`                           |
| `sale_order_items`       | `CaHeoShop.Sales.SaleOrderItem`                             | `CaHeoShop.Sales`                   | Purchased variant line item snapshots.                         | `research/013_table-sale-orders.md`                           |
| `recipients`             | `CaHeoShop.Customers.Recipient`                             | `CaHeoShop.Customers`               | Customer saved delivery recipients/addresses.                  | `research/014_table-recipients.md`                            |
| `store_settings`         | `CaHeoShop.StoreSettings.StoreSetting`                      | `CaHeoShop.StoreSettings`           | Single global row for contact, shipping, payment display copy. | `research/015_table-store-settings.md`                        |
| `fulfillment_procedures` | `CaHeoShop.FulfillmentProcedures.FulfillmentProcedure`      | `CaHeoShop.FulfillmentProcedures`   | Order preparation, printing, packing, shipping workflow.       | `research/016_table-fulfillment-procedures.md`                |
| `payment_procedures`     | `CaHeoShop.PaymentProcedures.PaymentProcedure`              | `CaHeoShop.PaymentProcedures`       | Order-related payment/refund workflow state.                   | `research/017_table-payment-procedures.md`                    |
| `return_procedures`      | `CaHeoShop.ReturnProcedures.ReturnProcedure`                | `CaHeoShop.ReturnProcedures`        | Return workflow state.                                         | `research/018_table-return-procedures-return-items.md`        |
| `return_items`           | `CaHeoShop.ReturnProcedures.ReturnItem`                     | `CaHeoShop.ReturnProcedures`        | Returned sale order item lines.                                | `research/018_table-return-procedures-return-items.md`        |
| `financial_transactions` | `CaHeoShop.Finance.FinancialTransaction`                    | `CaHeoShop.Finance`                 | Actual money movement ledger for income/expenses/refunds.      | `research/019_table-financial-transactions.md`                |
| `procedure_status_logs`  | `CaHeoShop.ProcedureStatusLogs.ProcedureStatusLog`          | `CaHeoShop.ProcedureStatusLogs`     | Append-only audit logs for procedure status changes.           | `research/020_table-procedure-status-logs.md`                 |
| `inventory_movements`    | `CaHeoShop.Inventory.InventoryMovement`                     | `CaHeoShop.Inventory`               | Future stock movement history.                                 | `research/021_table-inventory-movements.md`                   |

## Relationship Overview

Implemented:

```text
users has many users_tokens
users_tokens belongs to users
```

Catalog:

```text
products.collection_id -> collections.id
product_variants.product_id -> products.id
product_images.product_id -> products.id
```

Cart:

```text
cart_items.customer_id -> users.id
cart_items.product_variant_id -> product_variants.id
```

Sales:

```text
sale_orders.customer_id -> users.id
sale_order_items.sale_order_id -> sale_orders.id
sale_order_items.product_variant_id -> product_variants.id
```

Procedures:

```text
fulfillment_procedures.sale_order_id -> sale_orders.id
payment_procedures.sale_order_id -> sale_orders.id
return_procedures.sale_order_id -> sale_orders.id
return_items.return_procedure_id -> return_procedures.id
return_items.sale_order_item_id -> sale_order_items.id
```

Customers:

```text
recipients.customer_id -> users.id
```

Audit and future ledger:

```text
procedure_status_logs.changed_by_id -> users.id
financial_transactions.created_by_id -> users.id
inventory_movements.product_variant_id -> product_variants.id
inventory_movements.performed_by_id -> users.id
```

## Key Decisions

- The customer buys a selected `product_variant`, not a generic product.
- `cart_items` and `sale_order_items` should reference `product_variant_id`.
- `sale_order_items` should snapshot product name, product slug, variant name, unit price, production cost, line total, quantity, and image filename.
- `sale_orders` should stay focused on order header and snapshot data.
- Workflow state belongs to `fulfillment_procedures`, `payment_procedures`, and later `return_procedures`.
- Actual money movement belongs to `financial_transactions`, not `payment_procedures`.
- Procedure status history belongs to append-only `procedure_status_logs`.
- Store settings may provide reusable display copy but must not store order-specific payment state.
- Variant stock should not be deducted when an item is added to cart.

## Authentication Tables

### `users`

Fields:

| Field             | Type                                      | Required | Notes                                                         |
|-------------------|-------------------------------------------|----------|---------------------------------------------------------------|
| `id`              | primary key                               | yes      | Generated by Ecto/database.                                   |
| `email`           | `citext` in database, `:string` in schema | yes      | Case-insensitive email identity.                              |
| `hashed_password` | `string`                                  | no       | Password hash when password auth is used.                     |
| `confirmed_at`    | `utc_datetime`                            | no       | Email confirmation timestamp.                                 |
| `inserted_at`     | `utc_datetime`                            | yes      | Generated timestamp.                                          |
| `updated_at`      | `utc_datetime`                            | yes      | Generated timestamp.                                          |

Indexes:

```elixir
create unique_index(:users, [:email])
```

### `users_tokens`

Fields:

| Field              | Type                      | Required | Notes                           |
|--------------------|---------------------------|----------|---------------------------------|
| `id`               | primary key               | yes      | Generated by Ecto/database.     |
| `user_id`          | foreign key to `users.id` | yes      | Deletes with user.              |
| `token`            | `binary`                  | yes      | Raw or hashed token.            |
| `context`          | `string`                  | yes      | Token purpose.                  |
| `sent_to`          | `string`                  | no       | Email address for token flows.  |
| `authenticated_at` | `utc_datetime`            | no       | Recent authentication time.     |
| `inserted_at`      | `utc_datetime`            | yes      | Generated timestamp.            |

Indexes:

```elixir
create index(:users_tokens, [:user_id])
create unique_index(:users_tokens, [:context, :token])
```

## Proposed Core Fields

### `collections`

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

### `products`

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

### `product_variants`

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

### `product_images`

```text
id
product_id
filename
display_order
inserted_at
updated_at
```

### `cart_items`

```text
id
customer_id
product_variant_id
quantity
inserted_at
updated_at
```

### `sale_orders`

```text
id
order_number
customer_id
customer_name_snapshot
customer_email_snapshot
customer_phone_snapshot
recipient_fullname
recipient_phone_number
recipient_address
subtotal_amount
shipping_fee
discount_amount
total_amount
payment_method
payment_reference
customer_note
admin_note
inserted_at
updated_at
```

### `sale_order_items`

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

### `fulfillment_procedures`

```text
id
sale_order_id
status
confirmed_by_id
confirmed_at
started_preparing_at
ready_to_ship_at
shipped_at
completed_at
cancelled_at
admin_note
inserted_at
updated_at
```

### `payment_procedures`

```text
id
sale_order_id
return_procedure_id
financial_transaction_id
direction
payment_method
amount
status
reference
confirmed_by_id
confirmed_at
note
inserted_at
updated_at
```

### `return_procedures`

```text
id
sale_order_id
status
requested_by_id
approved_by_id
requested_at
approved_at
received_at
inspected_at
closed_at
reason
admin_note
inserted_at
updated_at
```

### `return_items`

```text
id
return_procedure_id
sale_order_item_id
quantity
condition
resolution
note
inserted_at
updated_at
```

### `recipients`

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

### `store_settings`

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

### `financial_transactions`

```text
id
direction
transaction_type
amount
occurred_at
payment_method
reference
related_type
related_id
created_by_id
note
inserted_at
updated_at
```

### `procedure_status_logs`

```text
id
procedure_type
procedure_id
from_status
to_status
changed_by_id
actor_type
note
metadata
inserted_at
```

### `inventory_movements`

```text
id
product_variant_id
movement_type
quantity_delta
quantity_after
related_type
related_id
performed_by_id
note
inserted_at
```

## Deferred Ideas

Defer until a future task requests them:

```text
cart header table
guest checkout tables
shipping provider tables
payment gateway integration tables
product bundle tables
media asset table
generic status_logs
structured address tables
product variant image gallery
```

## Research References

```text
research/004-commerce-order-flow.md
research/009_existing-tables.md
research/010_table-collections.md
research/011-table-products-product-images.md
research/012-table-cart-items.md
research/013_table-sale-orders.md
research/014_table-recipients.md
research/015_table-store-settings.md
research/016_table-fulfillment-procedures.md
research/017_table-payment-procedures.md
research/018_table-return-procedures-return-items.md
research/019_table-financial-transactions.md
research/020_table-procedure-status-logs.md
research/021_table-inventory-movements.md
```
