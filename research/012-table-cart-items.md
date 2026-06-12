# Cart Items Table Research

## 1. Overview

This document proposes the first database shape for authenticated cart line items.

Current `/cart` and `/checkout` pages are mock-only. This research does not implement cart persistence, checkout, order creation, inventory validation, or migrations.

## 2. Current UI Findings

Current cart page shows:

```text
product image
product name
product price
quantity controls
subtotal
shipping note
checkout link
```

Current checkout page reads the same mock cart items and shows an order summary.

Mock cart items currently look like:

```text
%{product: product, quantity: quantity}
```

## 3. Commerce Flow Requirements

`research/004-commerce-order-flow.md` recommends:

```text
cart_items.customer_id
cart_items.product_variant_id
cart_items.quantity
```

Cart items are cleared only after these order creation steps succeed:

```text
create sale_order
create sale_order_items
create fulfillment_procedure
create payment_procedure
clear cart_items
```

Cart conversion stages are not persistent cart item statuses.

## 4. Customer Relationship

Use existing authenticated users:

```text
cart_items.customer_id -> users.id
```

Use `customer_id` because the user is acting as buyer/customer. Guest carts are deferred.

## 5. Product Variant Relationship

Use:

```text
cart_items.product_variant_id -> product_variants.id
```

`product_id` is not enough because selected variants can affect price, production cost, stock, image, and option label.

Do not snapshot price in active cart items. Read current price through the selected variant. Price snapshots belong to sale order items.

## 6. Proposed `cart_items` Table

Recommended fields:

```text
id
customer_id
product_variant_id
quantity
inserted_at
updated_at
```

Each `customer_id + product_variant_id` pair should have one row. Updating cart quantity should update the row.

## 7. Constraints and Indexes

Recommended:

```elixir
create index(:cart_items, [:customer_id])
create index(:cart_items, [:product_variant_id])
create unique_index(:cart_items, [:customer_id, :product_variant_id])
create constraint(:cart_items, :quantity_positive, check: "quantity > 0")
```

Recommended delete behavior:

```text
customer_id: on_delete delete_all
product_variant_id: on_delete restrict
```

## 8. Deferred Cart Header

A separate `carts` header table is deferred until the app needs guest carts, abandoned carts, cart expiration, cart lifecycle status, or cart merge behavior.

## 9. Naming

Recommended:

```text
Table: cart_items
Schema: CaHeoShop.Carts.CartItem
Context: CaHeoShop.Carts
```

## 10. Open Questions

- Should checkout require login before cart persistence exists?
- Should cart updates validate against stock immediately or only at checkout?
- Should variant deletion be blocked while active cart items reference it?

## 11. Final Recommendation

Use a single `cart_items` table with `customer_id`, `product_variant_id`, and positive `quantity`. Defer cart headers and guest carts.
