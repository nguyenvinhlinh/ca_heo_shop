# Task 014: Research Fulfillment Procedures Database Schema

## Objective

Research the fulfillment workflow table proposed by `research/004-commerce-order-flow.md`, then propose a database schema for:

```text
fulfillment_procedures
```

This task is research only. Do not create migrations, Ecto schemas, Ecto contexts, Repo queries, seeds, tests, real fulfillment behavior, inventory behavior, or audit log behavior.

## Deliverable

Create:

```text
research/016_table-fulfillment-procedures.md
```

The document should explain how the shop prepares, prints, packs, ships, or hands over a sale order.

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
```

If `research/013_table-sale-orders.md` does not exist, document that clearly.

## Scope

Research:

```text
fulfillment_procedures
```

The commerce flow recommends:

```text
sale_order has one fulfillment_procedure
fulfillment_procedure belongs to sale_order
```

Recommended first status values from `research/004-commerce-order-flow.md`:

```text
unfulfilled
confirmed
preparing
ready_to_ship
shipping
completed
cancelled
```

## Fields To Evaluate

Evaluate at minimum:

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

Explain which timestamp fields are needed now and which can be deferred.

## Relationships To Evaluate

Evaluate:

```text
fulfillment_procedures.sale_order_id -> sale_orders.id
fulfillment_procedures.confirmed_by_id -> users.id
```

Also explain how future `procedure_status_logs` records should audit status changes without duplicating the fulfillment procedure row.

## Inventory Boundary

Document the stock implication from `research/004-commerce-order-flow.md`:

```text
do not deduct stock when item is added to cart
deduct or reserve stock at admin confirmation or fulfillment start
```

Do not design full `inventory_movements` in this task.

## Expected Output Structure

The file should contain:

1. Overview
2. Current UI Findings
3. Fulfillment Procedure Meaning
4. Status Recommendation
5. Proposed `fulfillment_procedures` Table
6. Field-by-Field Explanation
7. Relationships
8. Inventory Boundary
9. Audit Log Boundary
10. Indexes and Constraints
11. Recommended Schema/Context Naming
12. Optional or Deferred Fields
13. Open Questions
14. Final Recommendation

## Success Criteria

The task is complete when:

* `research/016_table-fulfillment-procedures.md` is created.
* `fulfillment_procedures` is clearly separated from `sale_orders`.
* Fulfillment statuses are documented.
* Sale order relationship is documented.
* Inventory and audit boundaries are documented.
* No production behavior or database implementation is created.
