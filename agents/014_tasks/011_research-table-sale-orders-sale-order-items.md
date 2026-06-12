# Task 010: Research Sale Orders and Sale Order Items Database Schema

## Objective

Research the current checkout, cart, account orders, admin orders, product, and customer/user model, then propose database schemas for:

```text
sale_orders
sale_order_items
```

The expected output is a research document:

```text
research/013_table-sale-orders.md
```

This task is for research and database design proposal only.

Do not create migrations, Ecto schemas, Ecto contexts, or real order behavior in this task.

---

## Deliverable

Create the following file:

```text
research/013_table-sale-orders.md
```

The document should describe the proposed database schema for `sale_orders` and `sale_order_items` based on:

* Current checkout UI
* Current cart UI
* Current account/orders UI
* Current admin orders UI
* Existing user/authentication model
* Product and cart schema research
* Expected ecommerce behavior for Ca Heo DIY

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
agents/014_task-workflow.md
research/004-commerce-order-flow.md
tasks/004-build-storefront-skeleton.md
tasks/005-admin-skeleton.md
tasks/007-research-current-database-model.md
tasks/009-research-table-carts.md
```

Also read these research files if they exist:

```text
research/010_table-collections.md
research/011-table-products-product-images.md
research/012-table-cart-items.md
```

Use `research/004-commerce-order-flow.md` as the primary source for order workflow boundaries:

```text
sale_orders = order header and order snapshot
sale_order_items = purchased item snapshots
fulfillment_procedures = fulfillment workflow and status
payment_procedures = payment workflow and status
return_procedures = return workflow and status
financial_transactions = actual money movement ledger
procedure_status_logs = audit history for procedure status changes
```

Inspect current code related to:

```text
/cart
/checkout
/orders
/account
/admin/orders
/admin/customers
/products
/products/:slug
lib/**/accounts
priv/repo/migrations
```

If some routes, files, or research documents do not exist yet, document that clearly.

---

## Core Rule

This is a research task only.

Do not create, modify, or run:

* Database migrations
* Ecto schemas
* Ecto contexts
* Repo queries
* Seeds
* Tests
* Real checkout behavior
* Real order creation
* Real payment behavior
* Real inventory deduction

The goal is to produce a database design proposal that can be reviewed before implementation.

---

## Tables To Research

Research these tables:

```text
sale_orders
sale_order_items
```

The `sale_orders` table represents the order header.

The `sale_order_items` table represents product line items inside an order.

This task should not fully design `fulfillment_procedures`, `payment_procedures`, `return_procedures`, `return_items`, `financial_transactions`, or `procedure_status_logs`. Those are separate procedure/ledger/audit research tasks.

Expected relationship:

```text
SaleOrder has many SaleOrderItems
SaleOrderItem belongs to SaleOrder
SaleOrderItem belongs to ProductVariant
```

The commerce order flow research separates order header data from procedure workflow state. This task should research `sale_orders` and `sale_order_items` only, while documenting how they relate to future procedure tables.

---

## Known Business Meaning

A `sale_order` represents a customer order created from checkout.

It should support:

* Customer order history
* Admin order management
* Recipient information
* Delivery/shipping address
* Total amount summary
* Relationship with ordered products through `sale_order_items`
* Relationship to future fulfillment and payment procedures

It should not be the source of truth for fulfillment, payment, return, financial ledger, or procedure audit status.

A `sale_order_item` represents one product line inside a sale order.

It should support:

* Product reference
* Product name snapshot
* Unit price snapshot
* Quantity
* Line total amount

---

## Known Basic Fields

### `sale_orders`

At minimum, research these recipient fields:

```text
recipient_address
recipient_fullname
recipient_phone_number
```

Important naming note:

The user mentioned `recipent_*`, but the research should evaluate and likely recommend the correct spelling:

```text
recipient_address
recipient_fullname
recipient_phone_number
```

Do not use misspelled column names unless there is a strong reason.

---

### `sale_order_items`

Research a practical first version of `sale_order_items`.

Expected basic relationship fields:

```text
sale_order_id
product_variant_id
quantity
```

Also research whether price, product, and variant snapshots are needed.

Possible fields to evaluate:

```text
product_name_snapshot
product_slug_snapshot
variant_name_snapshot
unit_price_snapshot
production_cost_snapshot
line_total_amount
image_filename_snapshot
```

These are important because product name and price may change after the order is created.

---

## Areas To Research

### Checkout Usage

Inspect the checkout page.

Research:

* What customer information is collected
* What recipient information is collected
* What delivery/shipping information is collected
* What payment information is displayed or implied
* What order summary data is shown
* Whether checkout currently uses mock data only
* What fields must be stored when an order is created in the future

Document what fields the checkout UI implies.

---

### Cart Usage

Inspect the cart page and cart research document.

Research:

* How cart rows should become sale order items
* Whether `sale_orders` should reference a cart
* Whether cart data should be copied into order data
* Whether pricing should be snapshotted at order creation

Do not design full cart behavior here.

Only document how cart relates to sale order creation.

---

### Customer / User Relationship

Inspect the existing authentication model.

Research whether `sale_orders` should reference:

```text
users.id
```

using a field such as:

```text
customer_id
```

or whether a separate future `customers` table is needed.

For the first implementation, prefer the simplest approach that fits the current authentication model.

The research document should explain:

* Whether current users represent customers
* Whether `customer_id` should be named `user_id`
* Tradeoffs between `customer_id` and `user_id`
* Whether guest checkout should be deferred

---

### Admin Orders Usage

Inspect admin order pages.

Research:

* What admin order list displays
* What order statuses appear in mock data
* What order detail information is implied
* Whether admin needs customer name, email, phone, total, status, created date
* Whether admin needs recipient address and phone number
* Whether admin needs fulfillment/shipping status
* Whether admin needs sale order item details

Document what fields the admin UI needs.

---

### Account Orders Usage

Inspect account/order pages.

Research:

* Whether customers can view their orders
* What order summary fields are shown
* Whether order number, status, total, and created date are needed
* Whether order detail route is implied
* Whether order items are shown to the customer

Document what fields the customer-facing order UI needs.

---

## Fields To Evaluate For `sale_orders`

The research document should evaluate whether these fields are needed for the first version of `sale_orders`.

### Identity and Relationship Fields

Evaluate:

```text
id
order_number
customer_id
```

Questions to answer:

* Should `order_number` be required?
* Should `order_number` be unique?
* Should `customer_id` reference `users.id`?
* Should guest orders be supported now or deferred?

---

### Recipient Fields

Evaluate:

```text
recipient_fullname
recipient_phone_number
recipient_address
```

These fields should snapshot the delivery recipient information at the time of order.

The research document should explain:

* Why recipient fields should be stored on the order
* Whether recipient fields should be required
* Whether recipient address should be one text field for now or split into multiple address fields later

For the first implementation, prefer a simple address model unless the current UI clearly requires more.

---

### Procedure Relationship and Cached Status Fields

`research/004-commerce-order-flow.md` recommends that workflow state lives in separate procedure tables:

```text
fulfillment_procedures.status
payment_procedures.status
return_procedures.status
```

For this task, evaluate whether `sale_orders` should:

```text
store no workflow status fields
store only optional cached current_fulfillment_status
store only optional cached current_payment_status
store only optional cached current_return_status
```

If cached fields are recommended, document that procedure tables remain the source of truth.

Do not make these first-version `sale_orders` source-of-truth fields:

```text
status
payment_status
fulfillment_status
```

Procedure statuses from the commerce flow should be documented as related/deferred tables:

```text
fulfillment_procedures.status:
unfulfilled
confirmed
preparing
ready_to_ship
shipping
completed
cancelled

payment_procedures.status for inbound payment:
unpaid
pending_confirmation
paid
failed
cancelled
refunded

payment_procedures.status for outbound payment:
pending
approved
processing
paid
failed
cancelled
```

Do not over-design full procedure tables in this task unless the task scope is explicitly expanded.

---

### Money Fields

Evaluate:

```text
subtotal_amount
shipping_fee
discount_amount
total_amount
```

The research document should recommend:

* Field type
* Whether values should be stored as integer VND
* Whether decimal should be avoided for VND pricing
* Required constraints
* Default values if any

Do not design full coupon/discount systems unless clearly needed.

---

### Customer Contact Snapshot Fields

Evaluate whether sale orders should snapshot customer contact information separately from recipient information.

Fields to evaluate:

```text
customer_name
customer_email
customer_phone
```

Reason:

* User profile information may change later
* Orders should preserve the customer contact information used when placing the order
* Recipient may be different from customer

Recommend whether these fields should exist in `sale_orders`.

---

### Payment Fields

Evaluate whether sale orders should store simple payment display information.

Fields to evaluate:

```text
payment_method
payment_reference
```

Possible payment method values:

```text
bank_transfer
cod
manual
qr_transfer
```

The project may use QR code, cash, COD, or manual bank transfer later, but do not implement payment logic in this task.

Payment workflow state belongs to future `payment_procedures`. Actual money movement belongs to future `financial_transactions`.

Only document the schema implications.

---

### Notes and Timestamps

Evaluate:

```text
customer_note
admin_note
confirmed_at
cancelled_at
completed_at
inserted_at
updated_at
```

Separate fields needed now from deferred fields.

---

## Fields To Evaluate For `sale_order_items`

The research document should evaluate whether these fields are needed for the first version of `sale_order_items`.

At minimum, evaluate:

```text
id
sale_order_id
product_variant_id
quantity
inserted_at
updated_at
```

Also evaluate:

```text
product_name_snapshot
product_slug_snapshot
variant_name_snapshot
unit_price_snapshot
production_cost_snapshot
line_total_amount
image_filename_snapshot
```

The research document should explain:

* Why order items should snapshot product name and price
* Why order items should reference the selected product variant
* Whether variant name should be snapshotted
* Whether production cost should be snapshotted for profit reporting
* Whether product or variant image filename should be snapshotted
* Whether product or variant deletion should be restricted if order items exist

---

## Relationship With Products

Research how `sale_order_items` should relate to product variants.

Questions to answer:

* Should `sale_order_items.product_variant_id` reference `product_variants.id`?
* What happens if a product or product variant is deleted?
* Should product name, variant name, and price be copied into `sale_order_items`?
* Should `sale_order_items` depend on current product/variant price or snapshot the price at order time?

Recommended direction to evaluate:

```text
Keep product_variant_id as a reference.
Snapshot name and price into sale_order_items.
Do not depend only on current product data for historical orders.
```

---

## Proposed Schema Content

The research document should propose first versions of both tables.

### `sale_orders`

At minimum, evaluate:

```text
id
order_number
customer_id
subtotal_amount
shipping_fee
discount_amount
total_amount
customer_name_snapshot
customer_email_snapshot
customer_phone_snapshot
recipient_fullname
recipient_phone_number
recipient_address
payment_method
payment_reference
customer_note
admin_note
confirmed_at
cancelled_at
completed_at
inserted_at
updated_at
```

### `sale_order_items`

At minimum, evaluate:

```text
id
sale_order_id
product_variant_id
product_name_snapshot
product_slug_snapshot
variant_name_snapshot
unit_price_snapshot
production_cost_snapshot
quantity
line_total_amount
image_filename_snapshot
inserted_at
updated_at
```

Do not include all fields blindly.

For each field, explain:

* Purpose
* Type
* Required or optional
* Default value if any
* Whether it is needed now or can be deferred

---

## Indexes and Constraints

The research document should recommend database constraints and indexes.

### `sale_orders`

Evaluate:

```text
unique index on order_number
index on customer_id
index on inserted_at
foreign key from sale_orders.customer_id to users.id
not null constraints
money amount constraints
```

### `sale_order_items`

Evaluate:

```text
index on sale_order_id
index on product_variant_id
foreign key from sale_order_items.sale_order_id to sale_orders.id
foreign key from sale_order_items.product_variant_id to product_variants.id
not null constraints
quantity positive constraint
money amount constraints
```

Also document tradeoffs.

---

## Naming Recommendation

Recommend final naming for:

```text
Table names
Schema modules
Context module
Relationship fields
Route usage
```

Examples to evaluate:

```text
sale_orders
sale_order_items
CaHeoShop.Sales.SaleOrder
CaHeoShop.Sales.SaleOrderItem
CaHeoShop.Sales
sale_orders.customer_id
sale_order_items.sale_order_id
sale_order_items.product_variant_id
```

Also evaluate whether the context should be:

```text
Sales
Orders
Commerce
```

Prefer simple and clear naming.

Do not implement naming changes in this task.

---

## Expected Output Structure

The file `research/013_table-sale-orders.md` should contain:

1. Overview
2. Current UI Findings
3. Checkout Requirements
4. Cart To Order Conversion
5. Customer/User Relationship Analysis
6. Admin Order Requirements
7. Customer Order History Requirements
8. Proposed `sale_orders` Table
9. Proposed `sale_order_items` Table
10. Field-by-Field Explanation
11. Procedure Relationship Recommendation
12. Money Field Recommendation
13. Recipient Information Recommendation
14. Product Snapshot Recommendation
15. Indexes and Constraints
16. Recommended Ecto Schema Shape
17. Recommended Migration Shape
18. Optional or Deferred Fields
19. Open Questions
20. Final Recommendation

---

## Recommended Migration Shape

The research document may include sample migration shapes as documentation only.

Do not create the actual migration files.

Example format:

```elixir
create table(:sale_orders) do
  add :order_number, :string, null: false
  add :customer_id, references(:users, on_delete: :restrict), null: false

  add :subtotal_amount, :integer, null: false, default: 0
  add :shipping_fee, :integer, null: false, default: 0
  add :discount_amount, :integer, null: false, default: 0
  add :total_amount, :integer, null: false, default: 0

  add :customer_name_snapshot, :string, null: false
  add :customer_email_snapshot, :string, null: false
  add :customer_phone_snapshot, :string, null: false

  add :recipient_fullname, :string, null: false
  add :recipient_phone_number, :string, null: false
  add :recipient_address, :text, null: false

  add :payment_method, :string
  add :payment_reference, :string

  add :customer_note, :text
  add :admin_note, :text

  add :confirmed_at, :utc_datetime
  add :cancelled_at, :utc_datetime
  add :completed_at, :utc_datetime

  timestamps(type: :utc_datetime)
end

create unique_index(:sale_orders, [:order_number])
create index(:sale_orders, [:customer_id])
create index(:sale_orders, [:inserted_at])
```

```elixir
create table(:sale_order_items) do
  add :sale_order_id, references(:sale_orders, on_delete: :delete_all), null: false
  add :product_variant_id, references(:product_variants, on_delete: :restrict), null: false

  add :product_name_snapshot, :string, null: false
  add :product_slug_snapshot, :string
  add :variant_name_snapshot, :string, null: false
  add :unit_price_snapshot, :integer, null: false
  add :production_cost_snapshot, :integer, null: false, default: 0
  add :quantity, :integer, null: false
  add :line_total_amount, :integer, null: false
  add :image_filename_snapshot, :string

  timestamps(type: :utc_datetime)
end

create index(:sale_order_items, [:sale_order_id])
create index(:sale_order_items, [:product_variant_id])
```

These samples should be treated as proposals, not implementation.

The final research document may recommend a smaller schema if some fields should be deferred.

---

## Research Guidance

During research, if additional fields appear necessary from the UI or business workflow, add them to the proposal.

However:

* Do not add fields just because ecommerce platforms usually have them.
* Keep the first implementation simple.
* Clearly separate required fields from deferred fields.
* Explain why each extra field is recommended.
* Do not design full payment gateway integration.
* Do not design full shipping provider integration.
* Do not design full inventory movement system.
* Do not implement order creation logic.

---

## Success Criteria

The task is complete when:

* `research/013_table-sale-orders.md` is created.
* The document is based on current UI and mock data observations.
* The proposed `sale_orders` table is documented.
* The proposed `sale_order_items` table is documented.
* Recipient fields are evaluated and named correctly.
* The customer/user relationship is clearly explained.
* The cart-to-order conversion is clearly explained.
* The relationship between `sale_orders` and `sale_order_items` is clearly explained.
* The relationship between `sale_order_items` and product variants is clearly explained.
* The relationship between sale orders and future fulfillment/payment/return procedures is clearly explained.
* Required fields are identified.
* Optional or deferred fields are separated from required fields.
* Procedure status fields are separated from sale order header fields.
* Money fields are recommended.
* Product snapshot fields are evaluated.
* Indexes and constraints are recommended.
* Open questions are documented.
* No database migration is created.
* No Ecto schema is created.
* No Ecto context is created.
* No Repo queries are added.
* No real checkout behavior is implemented.
* No real order creation behavior is implemented.
* No production code is changed unless needed only to inspect references.
