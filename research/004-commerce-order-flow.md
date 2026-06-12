# Commerce Order Flow Research

## 1. Overview

This document recommends the first commerce order flow for Ca Heo DIY.

Ca Heo DIY is a small owner-operated ecommerce shop selling self-made products, including 3D printed items, DIY kits, and related custom products.

This research focuses on business procedures before finalizing database schema design.

The recommended model separates:

```text
sale_orders
fulfillment_procedures
payment_procedures
return_procedures
return_items
financial_transactions
procedure_status_logs
```

Core direction:

```text
sale_orders = order header and order snapshot
fulfillment_procedures = fulfillment workflow
payment_procedures = order-related payment workflow
return_procedures = return workflow
return_items = returned order items
financial_transactions = actual money movement ledger
procedure_status_logs = audit history for procedure status changes
```

This is business research only.

It does not create migrations, Ecto schemas, Ecto contexts, Repo queries, seeds, tests, cart behavior, checkout behavior, order behavior, payment behavior, return behavior, inventory behavior, financial ledger behavior, or audit log behavior.

---

## 2. Current UI Findings

Current storefront UI includes:

```text
/products
/products/:slug
/collections
/collections/:slug
/cart
/checkout
/account
/account/settings
/orders
```

Current storefront pages are mock-only.

Current checkout UI asks for:

```text
full name
phone
email
address
city
order note
payment method placeholder
```

Current cart UI shows:

```text
product image
product name
product price
quantity
subtotal
shipping note placeholder
checkout link
```

Current admin UI includes:

```text
/admin
/admin/products
/admin/orders
/admin/customers
/admin/collections
/admin/settings
```

The admin order list shows:

```text
order number
customer
email
status
total
created date
```

Admin settings include contact, shipping note, and payment note placeholders.

Current implemented persistence contains only authentication-related tables.

Known table names should be verified from `priv/repo/migrations`:

```text
users
user_tokens or users_tokens
```

There is no real commerce persistence yet.

No real persistence exists yet for:

```text
products
product_variants
product_images
cart_items
sale_orders
sale_order_items
fulfillment_procedures
payment_procedures
return_procedures
return_items
recipients
financial_transactions
inventory_movements
procedure_status_logs
```

---

## 3. Customer Purchase Flow

Recommended first customer purchase flow:

```text
Browse products
Select product
Select product variant
Add selected variant to cart
Review cart
Update quantity or remove item
Checkout
Enter customer contact information
Enter delivery recipient information
Choose payment method
Place order
Sale order is created
Sale order items are created
Fulfillment procedure is created
Payment procedure is created
Cart items are cleared after successful order creation
Customer views order status
Admin reviews and processes order
```

Flow stages, not database statuses:

```text
browsing
cart_active
checking_out
order_placed
order_under_review
order_in_progress
order_completed
order_cancelled
```

The customer should buy a selected `product_variant`, not only a generic product.

Reason:

```text
variants can affect price
variants can affect production cost
variants can affect stock quantity
variants can affect display image
```

Example:

```text
Product: Universal Phone Stand
Variant: PLA Red
Price: 50,000 VND
```

Guest checkout should be deferred.

The current app already has authenticated users, while guest checkout would require:

```text
session identity
guest cart expiration
guest order lookup
merge-on-login behavior
privacy rules
support rules
```

Customer and recipient information should be snapshotted into the sale order.

Reason:

```text
account details may change later
saved recipient records may change later
historical orders must preserve checkout-time contact and delivery data
```

---

## 4. Cart To Order Conversion

Recommended cart-to-order procedure:

```text
Load current customer's cart_items
Validate cart is not empty
Validate each item has a selected product_variant
Validate each quantity is greater than zero
Read current product and variant display data
Read current variant price, production cost, stock, and image
Create sale order header
Create one sale order item per cart item
Create fulfillment procedure for the sale order
Create payment procedure for the sale order
Snapshot display, money, quantity, and image fields
Calculate subtotal and total from snapshots
Clear converted cart items after successful order creation
```

Cart conversion stages, not database statuses:

```text
cart_active
validating_cart
creating_order
creating_order_items
creating_procedures
converted
conversion_failed
cart_cleared
```

Cart items should reference:

```text
customer_id
product_variant_id
quantity
```

Sale order items should reference:

```text
sale_order_id
product_variant_id
quantity
```

Sale order items should snapshot values needed for historical display and reporting.

Recommended sale order item snapshots:

```text
product_name_snapshot
product_slug_snapshot
variant_name_snapshot
unit_price_snapshot
production_cost_snapshot
quantity
line_total_amount
image_filename_snapshot
```

Price and production cost should be copied at order creation time.

Completed order totals must not change when product or variant data changes later.

Cart items should be cleared only after all order creation steps succeed.

The order creation process should later run inside a database transaction so these steps succeed or fail together:

```text
create sale_order
create sale_order_items
create fulfillment_procedure
create payment_procedure
clear cart_items
```

If order creation fails, cart items should remain so the customer can retry.

---

## 5. Sale Order Header

`sale_orders` should represent the order header, not every workflow status.

Recommended responsibility of `sale_orders`:

```text
who bought
order number
customer snapshot
recipient snapshot
money summary
customer note
admin note
created time
```

Recommended data examples:

```text
order_number
customer_id
customer_name_snapshot
customer_email_snapshot
customer_phone_snapshot
recipient_fullname
recipient_phone_number
recipient_address
subtotal_amount
shipping_fee
discount_amount
total_amount
customer_note
admin_note
inserted_at
updated_at
```

`sale_orders` should stay focused on order identity and order snapshot data.

Workflow state should live in separate procedure tables:

```text
fulfillment_procedures.status
payment_procedures.status
return_procedures.status
```

This keeps `sale_orders` from mixing:

```text
order identity
payment workflow
fulfillment workflow
return workflow
audit behavior
financial ledger behavior
```

A future implementation may keep cached status fields on `sale_orders` for faster admin listing.

Example cached fields if needed later:

```text
current_fulfillment_status
current_payment_status
current_return_status
```

However, if the procedure-first model is adopted, procedure tables should be the source of truth.

---

## 6. Fulfillment Procedure

`fulfillment_procedures` should represent how the shop prepares and delivers an order.

Recommended first fulfillment flow:

```text
Order placed
Admin reviews order
Admin confirms or cancels fulfillment
Admin prepares, prints, assembles, or packs products
Order becomes ready to ship
Order is shipped or handed over
Fulfillment is completed
```

Recommended relationship:

```text
sale_order has one fulfillment_procedure
fulfillment_procedure belongs to sale_order
```

Recommended first `fulfillment_procedures.status` values:

```text
unfulfilled
confirmed
preparing
ready_to_ship
shipping
completed
cancelled
```

Meanings:

* `unfulfilled`: fulfillment has not started.
* `confirmed`: admin accepted responsibility to fulfill the order.
* `preparing`: item is being printed, assembled, packed, or prepared.
* `ready_to_ship`: item is ready for delivery or handoff.
* `shipping`: item is in delivery or handoff process.
* `completed`: delivery or handoff is done.
* `cancelled`: fulfillment stopped.

`preparing` should include:

```text
3D printing
assembly
DIY kit preparation
custom work
packing
manual delivery coordination
```

Admin should manually control important fulfillment transitions.

This fits the owner-operated shop and avoids premature automation.

If stock is not available, admin should:

```text
contact the customer
cancel fulfillment
delay fulfillment
handle substitution manually
```

Stock behavior should be researched separately, but first recommendation is:

```text
do not deduct stock when item is added to cart
deduct or reserve stock at admin confirmation or fulfillment start
```

---

## 7. Payment Procedure

`payment_procedures` should represent the order-related payment workflow.

Payment procedure is not the same as financial transaction ledger.

```text
payment_procedures = workflow state for order-related payment or refund
financial_transactions = actual money movement records
```

Recommended relationship:

```text
sale_order has many payment_procedures
payment_procedure belongs to sale_order
```

A sale order may have more than one payment procedure over time.

Examples:

```text
one inbound payment procedure for customer payment
one outbound payment procedure for refund
```

Recommended payment directions:

```text
inbound
outbound
```

Inbound means money moving from customer to shop.

Outbound means money moving from shop back to customer.

Recommended first payment methods:

```text
bank_transfer
qr_transfer
cod
cash
manual
```

---

## 8. Inbound Payment Procedure

Inbound payment means money moving from customer to shop.

Examples:

```text
customer pays by QR transfer
customer pays by bank transfer
customer pays by COD
customer pays by cash
admin manually confirms payment
```

Recommended first inbound payment flow:

```text
Order is created
Inbound payment procedure is created
Payment status starts unpaid
Customer pays or chooses COD
Manual payment waits for admin confirmation
Admin confirms, rejects, cancels, or later refunds payment
Payment becomes paid only after confirmation or COD collection
```

Recommended first inbound `payment_procedures.status` values:

```text
unpaid
pending_confirmation
paid
failed
cancelled
refunded
```

Meanings:

* `unpaid`: no payment is confirmed.
* `pending_confirmation`: customer may have paid, but admin has not verified it.
* `paid`: payment or COD collection is confirmed.
* `failed`: payment failed or could not be verified.
* `cancelled`: payment is no longer expected.
* `refunded`: money was returned to customer.

Manual bank transfer and QR transfer should require admin confirmation.

COD can move through fulfillment while payment is still unpaid or pending until delivery collection is confirmed.

Recommended fields to research later:

```text
sale_order_id
direction
payment_method
amount
status
reference
confirmed_by_id
confirmed_at
note
```

---

## 9. Outbound Payment Procedure

Outbound payment means money moving from shop back to customer.

Examples:

```text
refund after cancellation
refund after return
partial refund
manual bank transfer refund
```

Recommended future outbound payment flow:

```text
Refund is requested or required
Admin approves refund
Outbound payment procedure is created
Refund is processing
Admin sends refund manually
Refund is marked paid, failed, or cancelled
```

Recommended first outbound `payment_procedures.status` values:

```text
pending
approved
processing
paid
failed
cancelled
```

Outbound payment should be deferred for MVP unless refund tracking becomes a required admin workflow.

When implemented, outbound payment procedures should be linked to:

```text
sale_order
return_procedure optional
financial_transaction optional
```

A refund may be related to a return, but not every refund requires a return.

Example:

```text
cancelled paid order -> refund without return
return accepted -> refund after item inspection
```

---

## 10. Return Procedure

`return_procedures` should represent the return workflow.

Returns should be kept simple and can be deferred from MVP persistence.

Recommended future return flow:

```text
Customer requests return
Admin reviews request
Admin approves or rejects request
Customer sends item back if required
Admin receives item
Admin inspects item condition
Admin decides refund, exchange, or no refund
Admin closes return
```

Recommended relationship:

```text
sale_order has many return_procedures
return_procedure belongs to sale_order
return_procedure has many return_items
return_item belongs to return_procedure
return_item belongs to sale_order_item
```

Recommended future `return_procedures.status` values:

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

Meanings:

* `requested`: customer requested a return.
* `approved`: admin accepted the request.
* `rejected`: admin rejected the request.
* `received`: returned item arrived.
* `inspected`: admin inspected item condition.
* `refunded`: refund is complete.
* `exchanged`: exchange is complete.
* `closed`: return workflow is finished.
* `cancelled`: return stopped before completion.

Return item records should link to sale order items so partial returns are possible.

A return does not always create an outbound payment.

A return may end as:

```text
rejected
exchanged
closed without refund
refunded
```

Returned stock should not be added back automatically.

Reason:

```text
returned items may be damaged
returned items may be customized
returned items may not be resellable
admin should inspect condition first
```

---

## 11. Return Items

`return_items` should represent which order items are returned.

Recommended relationship:

```text
return_procedure has many return_items
return_item belongs to return_procedure
return_item belongs to sale_order_item
```

Recommended future fields to research:

```text
return_procedure_id
sale_order_item_id
quantity
condition
resolution
note
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

For MVP, `return_items` can be deferred.

Return item tracking becomes useful when the shop needs:

```text
partial returns
inspection history
refund per item
exchange per item
inventory restore decisions
```

---

## 12. Financial Transactions

The project may need to track real money movements beyond customer order payments.

Because the admin UI may later support entering expenses such as buying PLA filament rolls, tools, shipping costs, or operating expenses, the future money ledger should not be limited to `payment_transactions`.

Recommended future table name:

```text
financial_transactions
```

Purpose:

```text
record actual money in
record actual money out
record customer payments
record refunds
record material expenses
record shipping expenses
record tool expenses
record operating expenses
record other income and expenses
```

Recommended direction values:

```text
inbound
outbound
```

Recommended transaction types to evaluate later:

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

Example customer payment:

```text
direction = inbound
transaction_type = customer_payment
amount = 150000
related_type = sale_order
related_id = sale_order_id
```

Example material expense:

```text
direction = outbound
transaction_type = material_expense
amount = 250000
note = Buy PLA Red 1kg roll
```

Do not force all financial transactions to belong to a sale order.

Some expenses, such as buying filament, may not relate to a specific order.

`financial_transactions` should be deferred until the app needs:

```text
income tracking
expense tracking
refund history
cash ledger
reconciliation
financial reporting
```

---

## 13. Procedure Status Audit Log

Status changes should be auditable so the system can answer:

```text
who changed the status
when it changed
which procedure changed
previous status
new status
optional reason or note
```

Status changes that should eventually be logged:

```text
fulfillment_procedures.status
payment_procedures.status
return_procedures.status
```

Recommended first audit approach:

```text
procedure_status_logs
```

Recommended first fields:

```text
id
procedure_type
procedure_id
from_status
to_status
changed_by_id
note
inserted_at
```

Example:

```text
procedure_type = fulfillment_procedure
procedure_id = 123
from_status = preparing
to_status = ready_to_ship
changed_by_id = admin_user_id
```

`changed_by_id` should reference the user who performed the change when there is one.

If a future automatic system process changes a status, `changed_by_id` can be nullable and the system actor can be represented by a note or future `actor_type` field.

Audit logs should be append-only.

They should not be edited through normal admin workflows.

If a note is wrong, add another log entry instead of rewriting history.

If generic procedure logging feels too broad during implementation, use a focused log table first.

Possible focused log table:

```text
fulfillment_procedure_status_logs
```

Then defer generic logging.

However, if all procedures share the same status transition pattern, `procedure_status_logs` is likely simpler long-term.

---

## 14. Stock and Inventory Impact

Stock should be considered at variant level because selected variants can have different stock quantities.

Recommended first stock rules:

* Do not deduct stock when adding an item to cart.
* Validate quantity against current stock before order creation.
* Re-check stock during admin review.
* Deduct or reserve stock when admin confirms the order or starts fulfillment.
* Restore stock if an order is cancelled before fulfillment consumes it.
* Do not automatically restore returned items.
* Admin should inspect returned item condition before increasing stock.

Recommended first timing:

```text
Deduct stock at admin confirmation.
```

This fits a manual owner-operated workflow because admin confirms the order after reviewing stock and feasibility.

Open stock timing decision:

```text
Deduct at admin confirmation
or
Deduct when fulfillment starts
```

For the first real version, admin confirmation is simpler.

Full inventory movement tracking should be deferred until the shop needs:

```text
stock adjustment history
production batches
damaged return tracking
manual stock correction
audit-grade stock reporting
material inventory
```

Future table to consider:

```text
inventory_movements
```

---

## 15. Database Implications

Future database design should account for:

```text
cart_items
sale_orders
sale_order_items
fulfillment_procedures
payment_procedures
return_procedures
return_items
recipients
procedure_status_logs
financial_transactions
inventory_movements
```

Implications:

* `cart_items`: needed for persistent authenticated carts and selected variant quantities.
* `sale_orders`: needed for order headers, customer snapshots, recipient snapshots, totals, and notes.
* `sale_order_items`: needed to snapshot purchased item details.
* `fulfillment_procedures`: needed to track preparation, printing, packing, shipping, and completion workflow.
* `payment_procedures`: needed to track order-related payment or refund workflow.
* `return_procedures`: defer until return management is built.
* `return_items`: defer until partial returns are tracked.
* `recipients`: useful for reusable delivery information, but sale order snapshots can work first.
* `procedure_status_logs`: useful for audit history of fulfillment, payment, and return status changes.
* `financial_transactions`: defer until the app needs a real money ledger, expenses, refunds, or reconciliation.
* `inventory_movements`: defer until simple variant stock quantity is not enough.

---

## 16. Tables Needed Soon

Needed soon:

```text
cart_items
sale_orders
sale_order_items
fulfillment_procedures
payment_procedures
```

Likely needed soon after real order management:

```text
procedure_status_logs
recipients
```

Reasons:

* `cart_items` supports persistent authenticated carts.
* `sale_orders` records order headers and snapshots.
* `sale_order_items` preserves what was bought.
* `fulfillment_procedures` tracks preparation, printing, packing, shipping, and completion.
* `payment_procedures` tracks order-related payment workflow without requiring a full financial ledger.
* `procedure_status_logs` gives accountability for manual admin status changes.
* `recipients` improves checkout reuse, but sale order snapshots can work before saved recipient CRUD.

---

## 17. Tables To Defer

Defer:

```text
return_procedures
return_items
financial_transactions
inventory_movements
generic status_logs
cart header table
guest checkout tables
shipping provider tables
payment gateway tables
```

Reasons:

* Return tables are unnecessary until in-app return tracking exists.
* `financial_transactions` are unnecessary until the app tracks expenses, refunds, reconciliation, or financial reporting.
* Inventory movements are unnecessary while simple variant stock is enough.
* Generic status logs add complexity before many workflows need shared logging.
* Guest checkout, shipping providers, and payment gateways are outside the small first implementation.

---

## 18. Open Questions

* Should checkout require login in the first real version?
* Should stock be deducted at admin confirmation or fulfillment start?
* Should bank transfer and QR transfer orders require payment confirmation before fulfillment starts?
* How should COD move from unpaid to paid after delivery?
* Should sale orders keep cached current statuses for admin list performance?
* Should `fulfillment_procedures` be one-to-one with `sale_orders`?
* Should `payment_procedures` support multiple records per order from the first version?
* Should procedure status logging cover fulfillment and payment procedures from the first implementation?
* Should system-triggered status changes use nullable `changed_by_id` or a dedicated system actor?
* Should saved recipients be implemented before real checkout or shortly after?
* Should refunds be represented first as outbound payment procedures or only after return management exists?
* Should `financial_transactions` be a standalone finance feature or introduced only after payment/refund procedures mature?
* Should cancelled paid orders require financial transaction tracking before a refund can be marked complete?
* Should return management be manual-only at first or have minimal return procedure persistence?

---

## 19. Final Recommendation

Use a simple authenticated commerce flow first:

```text
product_variant -> cart_items -> sale_orders -> sale_order_items
```

Recommended first direction:

* Customer buys a product variant.
* Cart rows reference `product_variant_id`.
* Checkout creates one sale order and one sale order item per cart item.
* Sale order items snapshot product, variant, money, quantity, and image details.
* Sale orders snapshot customer and recipient information.
* Sale orders stay focused on order header data.
* Fulfillment workflow lives in `fulfillment_procedures`.
* Payment workflow lives in `payment_procedures`.
* Return workflow later lives in `return_procedures` and `return_items`.
* Cart rows are cleared only after successful order creation.
* Admin manually controls important fulfillment and payment transitions.
* Procedure status changes should be append-only audited.
* Stock is not deducted at cart add.
* First stock deduction should happen at admin confirmation or fulfillment start.
* `financial_transactions` should be deferred until the shop needs real income/expense ledger, refund tracking, material expense tracking, or reconciliation.

Keep MVP small.

Defer:

```text
guest checkout
financial transaction ledger
return tables
inventory movement history
shipping integrations
payment gateways
generic audit logs
```

until the shop needs those workflows.
