# Task 019: Research Inventory Movements Database Schema

## Objective

Research the future stock history table mentioned by `research/004-commerce-order-flow.md`, then propose whether and how to design:

```text
inventory_movements
```

This task is research only. Do not create migrations, Ecto schemas, Ecto contexts, Repo queries, seeds, tests, real stock deduction behavior, or inventory behavior.

## Deliverable

Create:

```text
research/021_table-inventory-movements.md
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
research/011-table-products-product-images.md
research/016_table-fulfillment-procedures.md
research/018_table-return-procedures-return-items.md
```

If related research files are missing, document that clearly.

## Scope

Research whether `inventory_movements` should be implemented soon or deferred.

The commerce flow recommends:

```text
do not deduct stock when item is added to cart
deduct stock at admin confirmation or fulfillment start
restore stock after cancellation only when appropriate
do not automatically restore returned stock before admin inspection
```

## Movement Types To Evaluate

Evaluate possible movement types:

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

Keep the first recommendation simple.

## Fields To Evaluate

Evaluate:

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

Also evaluate whether explicit nullable relationship fields are clearer than polymorphic references:

```text
fulfillment_procedure_id
return_item_id
sale_order_item_id
```

## Boundary

This task should not implement inventory logic. It should only document when a movement table becomes necessary and how it would relate to product variants, fulfillment, and returns.

## Expected Output Structure

The file should contain:

1. Overview
2. Current UI Findings
3. Inventory Movement Meaning
4. Stock Timing Recommendation
5. Movement Type Recommendation
6. Proposed `inventory_movements` Table
7. Field-by-Field Explanation
8. Relationships
9. Fulfillment Boundary
10. Return Boundary
11. Indexes and Constraints
12. Recommended Schema/Context Naming
13. Optional or Deferred Fields
14. Open Questions
15. Final Recommendation

## Success Criteria

The task is complete when:

* `research/021_table-inventory-movements.md` is created.
* The task clearly evaluates whether inventory movements should be deferred.
* Variant-level stock relationship is documented.
* Fulfillment and return boundaries are documented.
* No production behavior or database implementation is created.
