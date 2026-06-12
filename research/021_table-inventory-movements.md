# Inventory Movements Table Research

## 1. Overview

This document evaluates future database tracking for:

```text
inventory_movements
```

`inventory_movements` should be deferred while simple `product_variants.stock_quantity` is enough.

## 2. Stock Timing Recommendation

From `research/004-commerce-order-flow.md`:

```text
do not deduct stock at cart add
validate stock before order creation
deduct or reserve stock at admin confirmation or fulfillment start
do not automatically restore returned stock before inspection
```

First practical timing:

```text
deduct stock at admin fulfillment confirmation
```

## 3. Movement Types

Possible future values:

```text
stock_in
stock_out
reservation
release_reservation
sale_deduction
return_restore
manual_adjustment
damage_writeoff
production_output
material_consumption
```

Keep the first version smaller if implemented.

## 4. Proposed `inventory_movements` Table

Recommended fields:

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

No `updated_at` is needed if movements are append-only.

## 5. Relationship Strategy

Recommended base relation:

```text
inventory_movements.product_variant_id -> product_variants.id
```

Polymorphic relation:

```text
related_type
related_id
```

can point at fulfillment procedures, return items, sale order items, or manual adjustments. Explicit nullable fields are an alternative but can become wide.

## 6. Boundaries

Fulfillment may trigger sale deduction. Returns may trigger restore or damage writeoff only after inspection. Financial transactions should track money, not stock.

## 7. Constraints and Indexes

Recommended:

```elixir
create index(:inventory_movements, [:product_variant_id])
create index(:inventory_movements, [:movement_type])
create index(:inventory_movements, [:related_type, :related_id])
create index(:inventory_movements, [:inserted_at])
create constraint(:inventory_movements, :quantity_delta_not_zero,
         check: "quantity_delta <> 0")
```

## 8. Naming

Recommended:

```text
Table: inventory_movements
Schema: CaHeoShop.Inventory.InventoryMovement
Context: CaHeoShop.Inventory
```

## 9. Open Questions

- Should reservations be represented as movements or a separate reservation table?
- Should `quantity_after` be required for auditability?
- Should material inventory be tracked separately from sellable product variants?

## 10. Final Recommendation

Defer `inventory_movements` until stock history, manual adjustments, damaged returns, material inventory, or audit-grade inventory reporting is required.
