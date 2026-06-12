# Task 016: Research Return Procedures and Return Items Database Schema

## Objective

Research the return workflow tables proposed by `research/004-commerce-order-flow.md`, then propose database schemas for:

```text
return_procedures
return_items
```

This task is research only. Do not create migrations, Ecto schemas, Ecto contexts, Repo queries, seeds, tests, real return behavior, refund behavior, inventory behavior, or audit log behavior.

## Deliverable

Create:

```text
research/018_table-return-procedures-return-items.md
```

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
research/013_table-sale-orders.md
research/017_table-payment-procedures.md
```

If payment procedure research does not exist yet, document that clearly.

## Scope

Research:

```text
return_procedures
return_items
```

Recommended relationships:

```text
sale_order has many return_procedures
return_procedure belongs to sale_order
return_procedure has many return_items
return_item belongs to return_procedure
return_item belongs to sale_order_item
```

## Status Values To Evaluate

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

## Return Item Values To Evaluate

Possible condition values:

```text
new
used
damaged
defective
unknown
```

Possible resolution values:

```text
refund
exchange
no_refund
store_credit
```

## Fields To Evaluate

For `return_procedures`, evaluate:

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

For `return_items`, evaluate:

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

## Boundaries

Document:

* A return does not always create an outbound payment.
* Returned stock should not be automatically restored.
* Refund workflow belongs to `payment_procedures`.
* Actual money movement belongs to `financial_transactions`.
* Status changes should later be audited by `procedure_status_logs`.

## Expected Output Structure

The file should contain:

1. Overview
2. Current UI Findings
3. Return Procedure Meaning
4. Return Item Meaning
5. Status Recommendation
6. Proposed `return_procedures` Table
7. Proposed `return_items` Table
8. Field-by-Field Explanation
9. Relationships
10. Refund Boundary
11. Inventory Boundary
12. Audit Log Boundary
13. Indexes and Constraints
14. Recommended Schema/Context Naming
15. Optional or Deferred Fields
16. Open Questions
17. Final Recommendation

## Success Criteria

The task is complete when:

* `research/018_table-return-procedures-return-items.md` is created.
* Return procedure and return item responsibilities are separated.
* Partial return support is evaluated.
* Refund and inventory boundaries are documented.
* No production behavior or database implementation is created.
