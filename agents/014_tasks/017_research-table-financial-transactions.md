# Task 017: Research Financial Transactions Database Schema

## Objective

Research the future money ledger table proposed by `research/004-commerce-order-flow.md`, then propose a database schema for:

```text
financial_transactions
```

This task is research only. Do not create migrations, Ecto schemas, Ecto contexts, Repo queries, seeds, tests, real payment behavior, accounting behavior, reports, or reconciliation behavior.

## Deliverable

Create:

```text
research/019_table-financial-transactions.md
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
research/017_table-payment-procedures.md
```

If payment procedure research does not exist yet, document that clearly.

## Scope

Research:

```text
financial_transactions
```

The commerce flow recommends this table for actual money movement, not payment workflow state.

## Values To Evaluate

Directions:

```text
inbound
outbound
```

Transaction types:

```text
customer_payment
refund
material_expense
shipping_expense
tool_expense
operating_expense
other_income
other_expense
```

## Fields To Evaluate

Evaluate:

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

Also evaluate whether polymorphic `related_type` and `related_id` are appropriate, or whether explicit nullable fields are simpler:

```text
sale_order_id
payment_procedure_id
return_procedure_id
```

## Business Boundary

Do not force every financial transaction to belong to a sale order. Material purchases, tool purchases, and operating expenses may not map to a specific customer order.

## Expected Output Structure

The file should contain:

1. Overview
2. Current UI Findings
3. Financial Transaction Meaning
4. Income and Expense Use Cases
5. Relationship To Payment Procedures
6. Direction and Transaction Type Recommendation
7. Proposed `financial_transactions` Table
8. Field-by-Field Explanation
9. Relationship Strategy
10. Indexes and Constraints
11. Recommended Schema/Context Naming
12. Optional or Deferred Fields
13. Open Questions
14. Final Recommendation

## Success Criteria

The task is complete when:

* `research/019_table-financial-transactions.md` is created.
* The ledger is clearly separated from payment workflow state.
* Income and expense cases are documented.
* Relationship strategy is evaluated.
* No production behavior or database implementation is created.
