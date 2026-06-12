# Fulfillment Procedures Table Research

## 1. Overview

This document proposes a first database shape for:

```text
fulfillment_procedures
```

`research/004-commerce-order-flow.md` separates fulfillment workflow from `sale_orders`. `sale_orders` stores order header/snapshot data; `fulfillment_procedures` stores preparation, printing, packing, shipping, and completion state.

This is research only. No migrations, schemas, contexts, Repo queries, inventory behavior, audit behavior, or fulfillment behavior are implemented.

## 2. Current UI Findings

Admin order UI is currently a mock order list with order number, customer, status, total, and created date. There is no admin fulfillment detail page yet.

The mock status column should eventually be derived from procedure state or cached from it.

## 3. Meaning

Recommended relationship:

```text
sale_order has one fulfillment_procedure
fulfillment_procedure belongs to sale_order
```

One fulfillment procedure per sale order is enough for the first version. Split shipments are deferred.

## 4. Status Recommendation

Recommended statuses:

```text
unfulfilled
confirmed
preparing
ready_to_ship
shipping
completed
cancelled
```

`preparing` includes 3D printing, assembly, DIY kit preparation, custom work, packing, and manual delivery coordination.

## 5. Proposed `fulfillment_procedures` Table

Recommended fields:

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

Only `sale_order_id` and `status` are required for a minimal workflow. Timestamp fields can be nullable and populated as transitions occur.

## 6. Relationships

Recommended:

```text
fulfillment_procedures.sale_order_id -> sale_orders.id
fulfillment_procedures.confirmed_by_id -> users.id
```

Use `on_delete: :delete_all` for `sale_order_id` only if non-final draft/test orders can be deleted. For historical orders, deletion should be restricted or avoided.

## 7. Inventory Boundary

Stock should not be deducted at cart add. First real deduction should happen at admin confirmation or fulfillment start. `inventory_movements` should be deferred unless stock history is required.

## 8. Audit Boundary

Status changes should later be logged by `procedure_status_logs`. The fulfillment row stores current state; logs store history.

## 9. Indexes and Constraints

Recommended:

```elixir
create unique_index(:fulfillment_procedures, [:sale_order_id])
create index(:fulfillment_procedures, [:status])
create index(:fulfillment_procedures, [:confirmed_by_id])
```

Validate status values in changesets first. Defer database enum types.

## 10. Naming

Recommended:

```text
Table: fulfillment_procedures
Schema: CaHeoShop.FulfillmentProcedures.FulfillmentProcedure
Context: CaHeoShop.FulfillmentProcedures
```

## 11. Open Questions

- Should stock deduct at `confirmed` or `preparing`?
- Should split shipments create multiple fulfillment procedures later?
- Should shipping tracking fields be added when a delivery workflow exists?

## 12. Final Recommendation

Create `fulfillment_procedures` as the source of truth for fulfillment status, one row per sale order, with nullable transition timestamps and future audit logs.
