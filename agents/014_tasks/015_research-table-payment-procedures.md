# Task 015: Research Payment Procedures Database Schema

## Objective

Research the order-related payment workflow table proposed by `research/004-commerce-order-flow.md`, then propose a database schema for:

```text
payment_procedures
```

This task is research only. Do not create migrations, Ecto schemas, Ecto contexts, Repo queries, seeds, tests, real payment behavior, refund behavior, financial ledger behavior, or audit log behavior.

## Deliverable

Create:

```text
research/017_table-payment-procedures.md
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
research/015_table-store-settings.md
```

If any research file is missing, document that clearly.

## Scope

Research:

```text
payment_procedures
```

The commerce flow recommends:

```text
sale_order has many payment_procedures
payment_procedure belongs to sale_order
```

Payment procedures represent workflow state. They are not the actual money ledger; that belongs to future `financial_transactions`.

## Status Values To Evaluate

Inbound payment statuses:

```text
unpaid
pending_confirmation
paid
failed
cancelled
refunded
```

Outbound payment statuses:

```text
pending
approved
processing
paid
failed
cancelled
```

Directions:

```text
inbound
outbound
```

Payment methods:

```text
bank_transfer
qr_transfer
cod
cash
manual
```

## Fields To Evaluate

Evaluate at minimum:

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

Explain which fields are required for first implementation and which should be deferred.

## Boundary With Store Settings

`store_settings` may store reusable payment instructions. It must not store order-specific payment state.

## Boundary With Financial Transactions

`payment_procedures` should track workflow. `financial_transactions` should track actual money movement and may be deferred.

## Expected Output Structure

The file should contain:

1. Overview
2. Current UI Findings
3. Payment Procedure Meaning
4. Inbound Payment Procedure
5. Outbound Payment Procedure
6. Status Recommendation
7. Proposed `payment_procedures` Table
8. Field-by-Field Explanation
9. Relationships
10. Store Settings Boundary
11. Financial Transaction Boundary
12. Audit Log Boundary
13. Indexes and Constraints
14. Recommended Schema/Context Naming
15. Optional or Deferred Fields
16. Open Questions
17. Final Recommendation

## Success Criteria

The task is complete when:

* `research/017_table-payment-procedures.md` is created.
* Inbound and outbound payment workflows are separated.
* Payment procedure status values are documented.
* The boundary with `financial_transactions` is clear.
* The boundary with `store_settings` is clear.
* No production behavior or database implementation is created.
