# Task 006: Research Commerce Order Flow

## Objective

Research the core commerce order flow for Ca Heo DIY before finalizing database schema design.

This task focuses on business procedures, not database implementation.

The research must cover:

* Customer purchase flow
* Cart-to-order conversion
* Fulfillment procedure
* Return procedure
* Payment procedure

  * Inbound payment
  * Outbound payment
* Sale order status changes
* Payment status changes
* Fulfillment status changes
* Return status changes
* Status change audit log
* Inventory / stock impact

The output of this task is a research document.

Do not create migrations, Ecto schemas, Ecto contexts, Repo queries, or production behavior in this task.

---

## Deliverable

Create the following file:

```text
research/004-commerce-order-flow.md
```

The document should describe the recommended business flow for customer purchase, order fulfillment, returns, payments, status transitions, and status audit logging.

This research will later guide database schema research for:

```text
cart_items
sale_orders
sale_order_items
recipients
payment_transactions
returns
return_items
inventory_movements
status_logs
sale_order_status_logs
```

---

## Required Reading

Before starting, read:

```text
AGENTS.md
agents/001_phoenix-agent.md
agents/010_business-context.md
agents/011_architecture.md
agents/012_database-model.md
agents/013_ui-system.md
```

Also inspect task files and research files related to:

```text
products
product_variants
product_images
cart / carts / cart_items
sale_orders
sale_order_items
recipients
store_settings
```

Expected files may include:

```text
tasks/007-research-table-products.md
tasks/009-research-table-carts.md
tasks/010-research-table-sale-orders.md
tasks/011-research-table-recipents.md
tasks/012-research-table-store-settings.md

research/010_table-collections.md
research/011-table-products-product-images.md
research/012-table-carts.md
research/013_table-sale-orders.md
research/014_table-recipents.md
research/015_table-store-settings.md
```

If some files do not exist yet, document that clearly.

---

## Core Rule

This is a business research task only.

Do not create, modify, or run:

* Database migrations
* Ecto schemas
* Ecto contexts
* Repo queries
* Seeds
* Tests
* Real cart behavior
* Real checkout behavior
* Real order creation
* Real payment behavior
* Real return behavior
* Real inventory movement behavior
* Real audit log behavior

The goal is to produce a clear business procedure document before database implementation.

---

## Business Context

Ca Heo DIY is a small personal ecommerce shop selling self-made products, including 3D printed items.

Important business characteristics:

* Some products may be stocked in advance.
* Some products may need preparation or printing after order confirmation.
* Products may have variants such as `PLA Red`, `PETG Black`, or `ABS White`.
* Variant may affect price, production cost, stock quantity, and image.
* Payment may be manual bank transfer, QR transfer, COD, or manual confirmation.
* Return and refund process should remain simple at first.
* The owner/admin manually reviews and controls important order transitions.
* When a status changes, the system should be able to know who changed it and when.

---

## Scope

This task should research and document these procedures:

```text
Customer purchase flow
Cart-to-order conversion
Fulfillment procedure
Return procedure
Inbound payment procedure
Outbound payment procedure
Order status lifecycle
Payment status lifecycle
Fulfillment status lifecycle
Return status lifecycle
Status change audit log
Inventory impact
```

The research should also explain how these procedures affect future database design.

---

## Customer Purchase Flow

Research and document the full customer purchase flow.

At minimum, cover:

```text
Browse products
Select product
Select product variant
Add to cart
Update cart quantity
Checkout
Select or enter recipient information
Choose payment method
Place order
Sale order created
Customer views order status
```

Important questions:

* Does the customer buy `product` or `product_variant`?
* Should cart items reference `product_variant_id`?
* When is a sale order created?
* When should cart items be cleared?
* Should guest checkout be supported now or deferred?
* Should customer address/recipient be snapshotted into the sale order?
* What customer information is required at checkout?
* What recipient information is required at checkout?

Recommended direction to evaluate:

```text
The customer buys a product variant, not a generic product.
cart_items should likely reference product_variant_id.
sale_order_items should likely reference product_variant_id and snapshot product/variant information.
```

---

## Cart To Order Conversion

Research how cart items become sale order items.

Important questions:

* Should cart items reference `product_variant_id`?
* Should sale order items reference `product_variant_id`?
* What fields must be snapshotted into sale order items?
* Should price be copied from variant at order creation?
* Should product/variant name be copied at order creation?
* Should production cost be copied for future profit reporting?
* Should variant image filename be snapshotted for historical order display?
* When should cart items be deleted or marked converted?

Recommended snapshot fields to evaluate:

```text
product_name_snapshot
variant_name_snapshot
unit_price_snapshot
production_cost_snapshot
quantity
line_total_amount
image_filename_snapshot
```

Do not implement cart-to-order conversion in this task.

---

## Fulfillment Procedure

Research how the shop handles an order after checkout.

At minimum, document the expected fulfillment flow:

```text
Order placed
Admin reviews order
Admin confirms order
Admin prepares / prints / packs product
Order becomes ready to ship
Order is shipped or handed over
Order is completed
```

Evaluate these order or fulfillment statuses:

```text
pending
confirmed
preparing
ready_to_ship
shipping
completed
cancelled
```

Explain the meaning of each status.

Important questions:

* Should `preparing` include 3D printing work?
* When should stock be reserved?
* When should stock be deducted?
* Can an order be cancelled after confirmation?
* What happens if stock is not available?
* Should fulfillment status be separate from payment status?
* Should fulfillment logs be deferred?
* Should admin be able to manually change order status?

Recommended first direction to evaluate:

```text
sale_orders should have a simple order/fulfillment status.
Status changes should be auditable.
Do not implement complex fulfillment logs in the first version unless clearly needed.
```

---

## Return Procedure

Research how product returns should work.

At minimum, document a simple return flow:

```text
Customer requests return
Admin reviews request
Admin approves or rejects request
Customer sends item back if required
Admin receives and inspects item
Admin closes return
Refund or exchange may happen if applicable
```

Evaluate possible return statuses:

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

Important questions:

* Should returns be supported in MVP or deferred?
* Should a return be linked to `sale_order`?
* Should return items link to `sale_order_items`?
* Can returns be partial?
* Does a return always create outbound payment?
* Should returned stock be added back?
* Should damaged returned items affect inventory differently?
* Should exchange be supported now or deferred?
* Should return status changes be audited?

Database implications to evaluate:

```text
returns
return_items
inventory_movements
outbound_payments
return_status_logs
```

Do not create these tables in this task.

---

## Payment Procedure

Research payment procedures separately from order fulfillment.

Payment must be separated into:

```text
Inbound payment
Outbound payment
```

Do not collapse payment behavior into one generic order status.

---

## Inbound Payment Procedure

Inbound payment means money moving from customer to shop.

Examples:

```text
Customer pays by QR transfer
Customer pays by bank transfer
Customer pays by COD
Admin manually confirms payment
```

Research a simple inbound payment flow:

```text
Order created
Payment is unpaid
Customer makes payment
Payment is waiting for confirmation if manual
Admin confirms payment
Payment becomes paid
```

Evaluate payment statuses:

```text
unpaid
pending_confirmation
paid
failed
cancelled
refunded
```

Important questions:

* Should `sale_orders.payment_status` be enough for MVP?
* Should a separate `payments` or `payment_transactions` table be added later?
* Should payment amount be snapshotted?
* Should bank transfer reference be stored?
* Should QR transfer be considered a payment method?
* How should COD be represented?
* Can order be fulfilled before payment is confirmed?
* Should admin manually confirm inbound payment?
* Should payment status changes be audited?

Payment methods to evaluate:

```text
bank_transfer
qr_transfer
cod
manual
```

Recommended first direction to evaluate:

```text
sale_orders should have payment_status.
Payment status changes should be auditable.
A separate payments table may be deferred unless multiple payment attempts or detailed transaction history is needed.
```

---

## Outbound Payment Procedure

Outbound payment means money moving from shop back to customer.

Examples:

```text
Refund after cancelled order
Refund after return
Partial refund
Manual bank transfer refund
```

Research a simple outbound payment flow:

```text
Refund requested
Admin approves refund
Refund is processing
Refund is paid
Refund is failed or cancelled if needed
```

Evaluate outbound payment statuses:

```text
pending
processing
paid
failed
cancelled
```

Important questions:

* Should outbound payments be part of a general `payment_transactions` table?
* Should inbound and outbound payments share one table with a `direction` field?
* Should refunds be linked to returns?
* Should refunds be linked to sale orders?
* Should refund amount be allowed to be partial?
* Should refund reason be stored?
* Should refund payment method be stored?
* Should outbound payment be deferred for MVP?
* Should outbound payment status changes be audited?

Database implications to evaluate:

```text
payment_transactions
returns
return_items
payment_status_logs
```

Do not implement payment tables in this task.

---

## Status Model Recommendation

The research document should recommend a simple first-version status model.

At minimum, evaluate these fields for future `sale_orders`:

```text
status
payment_status
fulfillment_status
```

Important:

Do not collapse everything into one generic `status` if separate statuses are needed.

Explain the difference between:

```text
Order status
Payment status
Fulfillment status
Return status
```

Example cases to support:

```text
Order is preparing while payment is paid.
Order is shipping while payment is unpaid for COD.
Order is cancelled and payment is refunded.
Return is approved while refund is still processing.
```

---

## Status Change Audit Log

Research how status changes should be audited.

The system should be able to answer:

```text
Who changed the status?
When was the status changed?
What was the previous status?
What is the new status?
Why was it changed, if a note was provided?
```

This applies to status changes such as:

```text
sale_order.status
sale_order.payment_status
sale_order.fulfillment_status
return.status
payment_transaction.status
```

Evaluate whether audit logs should be stored in:

```text
Option A:
A dedicated sale_order_status_logs table

Option B:
Separate log tables per workflow, such as:
- sale_order_status_logs
- payment_status_logs
- return_status_logs

Option C:
A generic status_logs table with entity_type and entity_id
```

For the first implementation, recommend the simplest approach that still gives useful audit history.

Possible fields to evaluate:

```text
id
entity_type
entity_id
status_field
from_status
to_status
changed_by_id
changed_at
note
metadata
inserted_at
```

If recommending a specific table for sale orders, evaluate:

```text
sale_order_id
status_field
from_status
to_status
changed_by_id
note
inserted_at
```

Important questions:

* Should `changed_by_id` reference `users.id`?
* Should customer-triggered status changes be logged?
* Should admin-triggered status changes be logged?
* Should automatic system-triggered status changes be logged?
* How should system changes be represented if no user performed the change?
* Should audit logs be append-only?
* Should audit logs be editable? Prefer no.
* Should status logs be required for every status transition?

Recommended direction to evaluate:

```text
Status changes should be append-only audit records.
Each record should store from_status, to_status, changed_by_id, timestamp, and optional note.
For MVP, sale_order status logging may be enough.
Payment/return logs can be deferred or designed as generic status_logs.
```

Do not implement audit log behavior in this task.

---

## Stock and Inventory Impact

Research how stock should be affected by commerce flow.

Important questions:

* Should stock be deducted when item is added to cart?
* Should stock be deducted when order is placed?
* Should stock be deducted when order is confirmed?
* Should stock be deducted when fulfillment starts?
* Should stock be restored when an order is cancelled?
* Should stock be restored when return is received?
* Should product variant stock be used instead of product stock?
* Should inventory movements be recorded later?

Recommended direction to evaluate:

```text
Do not deduct stock when adding to cart.
Stock should likely be reserved or deducted during order confirmation or fulfillment.
Variant-level stock should be considered if product_variants exist.
```

Do not implement inventory movement logic in this task.

---

## Database Implications

The research document should summarize which database tables are affected.

Possible future tables:

```text
cart_items
sale_orders
sale_order_items
recipients
payment_transactions
returns
return_items
inventory_movements
sale_order_status_logs
status_logs
```

For each table, briefly explain whether it is:

```text
needed soon
can be deferred
open question
```

Do not design complete schemas for all these tables.

Only document business implications.

---

## Expected Output Structure

The file `research/004-commerce-order-flow.md` should contain:

1. Overview
2. Current UI Findings
3. Customer Purchase Flow
4. Cart To Order Conversion
5. Fulfillment Procedure
6. Return Procedure
7. Inbound Payment Procedure
8. Outbound Payment Procedure
9. Order Status Recommendation
10. Payment Status Recommendation
11. Fulfillment Status Recommendation
12. Return Status Recommendation
13. Status Change Audit Log Recommendation
14. Stock and Inventory Impact
15. Database Implications
16. Tables Needed Soon
17. Tables To Defer
18. Open Questions
19. Final Recommendation

---

## Research Guidance

During research, if additional procedure steps, statuses, or audit log requirements appear necessary, add them to the proposal.

However:

* Do not over-design enterprise ecommerce workflows.
* Keep the first implementation simple.
* Clearly separate MVP needs from deferred needs.
* Explain why each status or procedure step is recommended.
* Explain why each audit log table is recommended or deferred.
* Do not design full payment gateway integration.
* Do not design full shipping provider integration.
* Do not design full inventory movement system.
* Do not implement business logic.
* Do not create database tables.

---

## Success Criteria

The task is complete when:

* `research/004-commerce-order-flow.md` is created.
* Customer purchase flow is documented.
* Fulfillment procedure is documented.
* Return procedure is documented.
* Inbound payment procedure is documented.
* Outbound payment procedure is documented.
* Order status recommendation is documented.
* Payment status recommendation is documented.
* Fulfillment status recommendation is documented.
* Return status recommendation is documented.
* Status change audit log recommendation is documented.
* The document explains how to know who changed a status and when.
* Cart-to-order conversion is documented.
* Stock and inventory impact is documented.
* Database implications are summarized.
* Tables needed soon are separated from deferred tables.
* Open questions are documented.
* No database migration is created.
* No Ecto schema is created.
* No Ecto context is created.
* No Repo queries are added.
* No real cart behavior is implemented.
* No real checkout behavior is implemented.
* No real order behavior is implemented.
* No real payment behavior is implemented.
* No real return behavior is implemented.
* No real audit log behavior is implemented.
* No production code is changed unless needed only to inspect references.
