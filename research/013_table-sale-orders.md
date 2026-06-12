# Sale Orders and Sale Order Items Research

## 1. Overview

This document proposes first database shapes for:

```text
sale_orders
sale_order_items
```

Per `research/004-commerce-order-flow.md`, `sale_orders` stores order header/snapshot data. Fulfillment, payment, return, financial ledger, and procedure audit state belong to separate procedure/ledger/audit tables.

This is research only. No migrations, schemas, contexts, Repo queries, checkout behavior, order behavior, payment behavior, or fulfillment behavior are implemented.

## 2. Current UI Findings

Checkout UI collects customer name, phone, email, address, city, order note, and payment placeholder. Admin order list shows order number, customer, email, status, total, and created date. Customer orders page shows order id, status, total, and note.

The visible admin/customer `status` should be treated as a display concern until procedure tables exist.

## 3. Cart To Order Conversion

Order creation should:

```text
load cart_items
validate product_variant_id and quantity
create sale_orders row
create sale_order_items rows
create fulfillment_procedure
create payment_procedure
clear cart_items after success
```

Use a database transaction when implemented later.

## 4. Proposed `sale_orders` Table

Recommended fields:

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

Do not make `status`, `payment_status`, or `fulfillment_status` source-of-truth fields on `sale_orders`. If cached current statuses are added later for admin list performance, document the related procedure tables as source of truth.

## 5. Proposed `sale_order_items` Table

Recommended fields:

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

Use `product_variant_id`, not `product_id`, because the selected variant determines price, cost, stock, image, and option label.

## 6. Money Fields

Use integer VND:

```text
subtotal_amount
shipping_fee
discount_amount
total_amount
unit_price_snapshot
production_cost_snapshot
line_total_amount
```

Amounts should be non-negative. `line_total_amount = unit_price_snapshot * quantity`.

## 7. Recipient and Customer Snapshots

Snapshot customer and recipient fields at checkout time because user profile and saved recipient records may change later.

`sale_orders.recipient_id` can be deferred until checkout supports selecting saved recipients. Snapshot fields remain required for historical display.

## 8. Relationships

Recommended:

```text
sale_orders.customer_id -> users.id
sale_order_items.sale_order_id -> sale_orders.id
sale_order_items.product_variant_id -> product_variants.id
```

Future procedure relationships:

```text
sale_order has one fulfillment_procedure
sale_order has many payment_procedures
sale_order has many return_procedures
```

## 9. Constraints and Indexes

Recommended:

```elixir
create unique_index(:sale_orders, [:order_number])
create index(:sale_orders, [:customer_id])
create index(:sale_orders, [:inserted_at])

create index(:sale_order_items, [:sale_order_id])
create index(:sale_order_items, [:product_variant_id])
create constraint(:sale_order_items, :quantity_positive, check: "quantity > 0")
```

Add non-negative constraints for money fields.

## 10. Naming

Recommended:

```text
Tables: sale_orders, sale_order_items
Schemas: CaHeoShop.Sales.SaleOrder, CaHeoShop.Sales.SaleOrderItem
Context: CaHeoShop.Sales
```

## 11. Open Questions

- Should sale orders cache current fulfillment/payment/return statuses for faster admin lists?
- Should order numbers be sequential, date-prefixed, or random?
- Should payment display fields stay on `sale_orders` after `payment_procedures` exists?

## 12. Final Recommendation

Keep `sale_orders` focused on order header and snapshot data. Keep line item snapshots on `sale_order_items`. Put workflow state in procedure tables.
