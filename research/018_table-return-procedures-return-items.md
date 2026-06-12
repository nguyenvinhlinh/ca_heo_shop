# Return Procedures and Return Items Research

## 1. Overview

This document proposes future database shapes for:

```text
return_procedures
return_items
```

Return persistence is deferred until in-app return management exists.

## 2. Current UI Findings

There is no current return request, return review, or return detail UI. Admin orders and customer orders are mock lists only.

## 3. Return Procedure Meaning

Recommended relationship:

```text
sale_order has many return_procedures
return_procedure belongs to sale_order
return_procedure has many return_items
return_item belongs to return_procedure
return_item belongs to sale_order_item
```

## 4. Status Recommendation

Recommended statuses:

```text
requested
approved
rejected
received
inspected
refunded
exchanged
closed
cancelled
```

## 5. Proposed `return_procedures` Table

Recommended fields:

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

## 6. Proposed `return_items` Table

Recommended fields:

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

Possible `condition` values:

```text
new
used
damaged
defective
unknown
```

Possible `resolution` values:

```text
refund
exchange
no_refund
store_credit
```

## 7. Boundaries

A return does not always create an outbound payment. Refund workflow belongs to `payment_procedures`. Actual money movement belongs to `financial_transactions`.

Returned stock should not be restored automatically. Admin should inspect condition first.

Status changes should later be audited by `procedure_status_logs`.

## 8. Constraints and Indexes

Recommended:

```elixir
create index(:return_procedures, [:sale_order_id])
create index(:return_procedures, [:status])
create index(:return_items, [:return_procedure_id])
create index(:return_items, [:sale_order_item_id])
create constraint(:return_items, :quantity_positive, check: "quantity > 0")
```

## 9. Naming

Recommended:

```text
Schemas: CaHeoShop.ReturnProcedures.ReturnProcedure, CaHeoShop.ReturnProcedures.ReturnItem
Context: CaHeoShop.ReturnProcedures
```

## 10. Open Questions

- Should customers create return requests, or should admin create returns manually?
- Should exchanges create new sale orders later?
- Should return stock restoration require inventory movements?

## 11. Final Recommendation

Defer return tables until return management is needed. When implemented, use `return_procedures` for workflow and `return_items` for partial item tracking.
