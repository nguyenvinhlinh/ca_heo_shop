# Sale Orders and Sale Order Items Research

## 1. Overview

This document proposes the first database shape for completed customer orders:

```text
sale_orders
sale_order_items
```

The current storefront has `/cart`, `/checkout`, `/account`, and `/orders` pages, but they are mock-only. The admin area has `/admin/orders` and `/admin/customers`, also backed by mock data. There is no real checkout persistence, order creation, payment behavior, inventory deduction, or order management yet.

This task is research only. The examples below are proposals, not implemented migrations, Ecto schemas, contexts, Repo queries, seeds, tests, checkout behavior, payment behavior, inventory behavior, or order creation.

## 2. Current UI Findings

Current related routes:

- `/cart`
- `/checkout`
- `/account`
- `/orders`
- `/admin/orders`
- `/admin/customers`
- `/products`
- `/products/:slug`

Route placement:

- Storefront routes are inside the existing `:current_user` LiveView session and `:browser` pipeline because they work with or without authentication.
- Admin routes are inside the existing `:require_authenticated_user` LiveView session and authenticated browser scope because they are administrator workflows.

Current application tables:

```text
users
users_tokens
```

Business tables such as `products`, `product_variants`, `carts`, `sale_orders`, and `sale_order_items` are not implemented yet.

Existing relevant research:

- `research/010_table-collections.md`
- `research/011-table-products-product-images.md`
- `research/012-table-carts.md`

## 3. Checkout Requirements

The current checkout page renders a mock form with:

- customer full name
- customer phone
- customer email
- address
- city
- order note
- payment method placeholder
- place order button with no submit behavior

The current checkout summary renders:

- product image
- product name
- quantity
- subtotal

Schema implications:

- The order must snapshot customer contact information because account/profile fields can change after order creation.
- The order must snapshot delivery recipient information because the recipient can differ from the buyer in future flows.
- The order should store customer note.
- Payment fields should be simple placeholders for manual payment workflows; no payment gateway schema is needed yet.
- Money values should be stored on the order and order items so historical totals do not change when product prices change.

The current checkout UI has separate `address` and `city` inputs. For the first database design, store one `recipient_address` text field and compose it from the submitted address fields later. Split address columns can be added when there is a real address management workflow.

## 4. Cart To Order Conversion

Cart research recommends a single `carts` table where each row is one selected product variant:

```text
carts.customer_id -> users.id
carts.product_variant_id -> product_variants.id
carts.quantity
```

When checkout creates an order later:

- one `sale_orders` row should be created as the order header
- each cart row should become one `sale_order_items` row
- current variant price and production cost should be copied into the order item
- product and variant display values should be copied into the order item
- order totals should be calculated from the copied item values
- cart rows can be deleted after successful order creation

Do not reference the cart from `sale_orders` in the first version. The proposed cart table is line-item-only, not a durable cart header. A future cart header can be introduced if guest carts, abandoned cart tracking, or cart-to-order auditing becomes necessary.

## 5. Customer/User Relationship Analysis

There is no separate `customers` table yet. The current `users` table is the only persisted buyer identity available.

Recommended first relationship:

```text
sale_orders.customer_id -> users.id
```

Use the column name `customer_id` because it describes the user's role in the ecommerce workflow. In Ecto this can still point to `CaHeoShop.Accounts.User`:

```elixir
belongs_to :customer, CaHeoShop.Accounts.User, foreign_key: :customer_id
```

Tradeoff:

- `user_id` is technically clearer because it references `users.id`.
- `customer_id` is business clearer because the order belongs to a buyer/customer.

For the first implementation, prefer `customer_id` referencing `users.id`. Guest checkout should be deferred because it requires separate identity, contact, merge, fraud, and order lookup rules.

Use `on_delete: :restrict` for `customer_id`. Completed order history should not be deleted automatically if a user account is removed. Account deletion workflows can be designed later with anonymization or restricted deletes.

## 6. Admin Order Requirements

The current admin order list displays:

- order number
- customer name
- customer email
- status
- total
- created date
- row actions placeholder

Mock admin order statuses currently include:

- `Pending`
- `Paid`
- `Completed`
- `Draft`

Schema implications:

- `order_number` should be required and unique.
- `customer_name` and `customer_email` should be snapshotted for admin display.
- `status`, `payment_status`, and `fulfillment_status` are useful as separate fields because "paid" is a payment state, while "completed" is an order lifecycle state.
- `total_amount` and `inserted_at` are needed for the admin table.
- A future admin order detail page will need recipient information and order item details.

There is no current admin order detail route.

## 7. Customer Order History Requirements

The current account page shows a recent orders placeholder with:

- order id
- status
- total

The `/orders` page shows:

- order id
- status
- total
- note

Schema implications:

- customer order history needs `order_number`, `status`, `total_amount`, `customer_note`, and `inserted_at`.
- customer order detail pages are not implemented yet, but `sale_order_items` should support them later.
- customers should only see orders scoped to their current user when real queries are implemented.

## 8. Proposed `sale_orders` Table

Recommended first fields:

```text
id
order_number
customer_id
status
payment_status
fulfillment_status
subtotal_amount
shipping_fee
discount_amount
total_amount
customer_name
customer_email
customer_phone
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

Recommended first table meaning:

```text
sale_orders = immutable-ish order header created from checkout
```

The order header stores customer contact, recipient, status, payment, and total summary data. Product line details belong in `sale_order_items`.

## 9. Proposed `sale_order_items` Table

Recommended first fields:

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

Use `product_variant_id`, not only `product_id`, because the selected variant determines price, production cost, stock, image, and option label. The product can be reached through the variant relationship when current product data is still needed.

Snapshot fields preserve historical order data if product names, slugs, prices, costs, variant labels, or images change later.

## 10. Field-by-Field Explanation

### `sale_orders.id`

- Type: primary key
- Required: yes
- Default: generated by database
- Needed now: yes
- Purpose: stable order identity and parent key for order items

### `sale_orders.order_number`

- Type: string
- Required: yes
- Default: generated by application during order creation
- Needed now: yes
- Purpose: customer/admin-facing identifier such as `ORD-1024`

`order_number` should be unique. It should not rely on the internal integer primary key in UI.

### `sale_orders.customer_id`

- Type: foreign key to `users.id`
- Required: yes for authenticated first version
- Default: none
- Needed now: yes
- Purpose: owner of the order

Guest checkout is deferred.

### `sale_orders.status`

- Type: string
- Required: yes
- Default: `pending`
- Needed now: yes
- Purpose: overall order lifecycle state

### `sale_orders.payment_status`

- Type: string
- Required: yes
- Default: `unpaid`
- Needed now: yes
- Purpose: payment lifecycle independent from order fulfillment

### `sale_orders.fulfillment_status`

- Type: string
- Required: yes
- Default: `unfulfilled`
- Needed now: yes
- Purpose: preparation and delivery lifecycle

### Money fields

Fields:

```text
subtotal_amount
shipping_fee
discount_amount
total_amount
```

- Type: integer VND
- Required: yes
- Default: `0`
- Needed now: yes
- Purpose: immutable order totals for admin and customer history

Use integer VND and avoid decimal money fields. All amount fields should be non-negative. `total_amount` should be calculated by the application as:

```text
subtotal_amount + shipping_fee - discount_amount
```

The database can enforce non-negative amounts, but cross-field total consistency is better handled in application changesets for the first version.

### Customer contact snapshot fields

Fields:

```text
customer_name
customer_email
customer_phone
```

- Type: string
- Required: `customer_email` yes, name and phone yes when checkout requires them
- Default: none
- Needed now: yes
- Purpose: preserve buyer contact information used when placing the order

These fields are separate from the `users` row because user email or future profile data may change.

### Recipient fields

Fields:

```text
recipient_fullname
recipient_phone_number
recipient_address
```

- Type: string for name and phone, text column for address
- Required: yes
- Default: none
- Needed now: yes
- Purpose: delivery contact/address snapshot

Use the correct spelling `recipient_*`, not `recipent_*`.

### Payment fields

Fields:

```text
payment_method
payment_reference
paid_at
```

Recommendation:

- include `payment_method` as optional string
- include `payment_reference` as optional string
- defer `paid_at` until real payment confirmation exists

Possible first payment methods:

```text
bank_transfer
cod
manual
qr_transfer
```

No payment gateway integration is implied.

### Notes and event timestamps

Fields:

```text
customer_note
admin_note
confirmed_at
cancelled_at
completed_at
```

- `customer_note`: optional text, needed now because checkout has an order note field
- `admin_note`: optional text, useful for owner-operated admin workflow
- `confirmed_at`: optional timestamp, useful when admin confirms the order
- `cancelled_at`: optional timestamp, useful when order is cancelled
- `completed_at`: optional timestamp, useful when order is completed

### `sale_order_items.sale_order_id`

- Type: foreign key to `sale_orders.id`
- Required: yes
- Default: none
- Needed now: yes
- Purpose: parent order relationship

Use `on_delete: :delete_all` so deleting a not-yet-final order row deletes its line items. In normal operations, completed orders should not be deleted casually.

### `sale_order_items.product_variant_id`

- Type: foreign key to `product_variants.id`
- Required: yes
- Default: none
- Needed now: yes
- Purpose: selected sellable option ordered by the customer

Use `on_delete: :restrict`. Order items should preserve a reference to the variant, and product/variant deletion should be blocked while historical order items reference it. If the business later needs product archival, add status/archive fields rather than deleting products.

### Product snapshot fields

Fields:

```text
product_name_snapshot
product_slug_snapshot
variant_name_snapshot
image_filename_snapshot
```

- Type: string
- Required: product name and variant name yes; slug and image optional
- Default: none
- Needed now: yes
- Purpose: preserve what the customer bought and what admin/customer order detail pages should display

### Item money fields

Fields:

```text
unit_price_snapshot
production_cost_snapshot
line_total_amount
```

- Type: integer VND
- Required: yes
- Default: `0` for production cost, none for selling price and line total
- Needed now: yes
- Purpose: preserve historical sale price, production cost, and line total

`line_total_amount` should be calculated as:

```text
unit_price_snapshot * quantity
```

Snapshotting production cost is useful for later profit reporting because variant production cost can change over time.

### `sale_order_items.quantity`

- Type: integer
- Required: yes
- Default: none
- Needed now: yes
- Purpose: purchased quantity

Quantity must be greater than `0`.

## 11. Status Model Recommendation

Recommended first order status values:

```text
pending
confirmed
processing
completed
cancelled
```

Recommended first payment status values:

```text
unpaid
pending
paid
failed
refunded
```

Recommended first fulfillment status values:

```text
unfulfilled
preparing
shipped
delivered
cancelled
```

Store these as strings in the first implementation. Do not create enum database types or a full state machine yet. Changesets can validate allowed values when schemas are implemented.

The admin mock status `Paid` maps to `payment_status = "paid"` and may leave `status = "confirmed"` or `status = "processing"`. Avoid using payment words as the only order lifecycle status.

## 12. Money Field Recommendation

Use integer VND for all money fields:

```text
subtotal_amount
shipping_fee
discount_amount
total_amount
unit_price_snapshot
production_cost_snapshot
line_total_amount
```

Reasons:

- VND does not need fractional cents in this app.
- integer math avoids decimal rounding issues.
- product variant research already recommends integer VND for prices and costs.

Do not add `currency` in the first version. The app is Vietnam-focused. If multiple currencies are needed later, add currency explicitly across product pricing and order snapshots.

## 13. Recipient Information Recommendation

Use these fields on `sale_orders`:

```text
recipient_fullname
recipient_phone_number
recipient_address
```

These should be required because a placed order needs delivery contact information. Store them directly on the order even if future saved recipients are added.

Do not split address into ward, district, city, province, or postal code yet. The current checkout UI does not require a structured address model, and task 011 is reserved for recipient/address research.

## 14. Product Snapshot Recommendation

Use `product_variant_id` as the live reference and snapshot display/money values onto `sale_order_items`.

Recommended relationship:

```text
sale_order_items.product_variant_id -> product_variants.id
```

Rejected as the only relationship:

```text
sale_order_items.product_id -> products.id
```

`product_id` alone cannot determine the selected variant, price, production cost, stock, image, or option label. A selected variant already belongs to a product, so product-level data can be reached through the variant when needed.

Historical order screens should not depend only on current product data. Snapshot at least:

- product name
- product slug
- variant name
- unit selling price
- production cost
- line total
- image filename when available

## 15. Indexes and Constraints

Recommended `sale_orders` constraints:

- `order_number` not null
- `customer_id` not null
- `status` not null
- `payment_status` not null
- `fulfillment_status` not null
- money fields not null
- money fields greater than or equal to `0`
- recipient fields not null
- required customer contact fields not null

Recommended `sale_orders` foreign keys:

```text
sale_orders.customer_id -> users.id
```

Recommended `sale_orders` indexes:

```elixir
create unique_index(:sale_orders, [:order_number])
create index(:sale_orders, [:customer_id])
create index(:sale_orders, [:status])
create index(:sale_orders, [:payment_status])
create index(:sale_orders, [:fulfillment_status])
create index(:sale_orders, [:inserted_at])
```

Recommended `sale_order_items` constraints:

- `sale_order_id` not null
- `product_variant_id` not null
- product and variant snapshots not null where needed for display
- `unit_price_snapshot` not null and greater than or equal to `0`
- `production_cost_snapshot` not null and greater than or equal to `0`
- `line_total_amount` not null and greater than or equal to `0`
- `quantity` not null and greater than `0`

Recommended `sale_order_items` foreign keys:

```text
sale_order_items.sale_order_id -> sale_orders.id
sale_order_items.product_variant_id -> product_variants.id
```

Recommended `sale_order_items` indexes:

```elixir
create index(:sale_order_items, [:sale_order_id])
create index(:sale_order_items, [:product_variant_id])
```

## 16. Recommended Ecto Schema Shape

Documentation-only example:

```elixir
schema "sale_orders" do
  field :order_number, :string

  belongs_to :customer, CaHeoShop.Accounts.User, foreign_key: :customer_id
  has_many :sale_order_items, CaHeoShop.Sales.SaleOrderItem

  field :status, :string, default: "pending"
  field :payment_status, :string, default: "unpaid"
  field :fulfillment_status, :string, default: "unfulfilled"

  field :subtotal_amount, :integer, default: 0
  field :shipping_fee, :integer, default: 0
  field :discount_amount, :integer, default: 0
  field :total_amount, :integer, default: 0

  field :customer_name, :string
  field :customer_email, :string
  field :customer_phone, :string

  field :recipient_fullname, :string
  field :recipient_phone_number, :string
  field :recipient_address, :string

  field :payment_method, :string
  field :payment_reference, :string

  field :customer_note, :string
  field :admin_note, :string

  field :confirmed_at, :utc_datetime
  field :cancelled_at, :utc_datetime
  field :completed_at, :utc_datetime

  timestamps(type: :utc_datetime)
end
```

```elixir
schema "sale_order_items" do
  belongs_to :sale_order, CaHeoShop.Sales.SaleOrder
  belongs_to :product_variant, CaHeoShop.ProductVariants.ProductVariant

  field :product_name_snapshot, :string
  field :product_slug_snapshot, :string
  field :variant_name_snapshot, :string
  field :unit_price_snapshot, :integer
  field :production_cost_snapshot, :integer, default: 0
  field :quantity, :integer
  field :line_total_amount, :integer
  field :image_filename_snapshot, :string

  timestamps(type: :utc_datetime)
end
```

Recommended naming:

```text
Table names: sale_orders, sale_order_items
Schema modules: CaHeoShop.Sales.SaleOrder, CaHeoShop.Sales.SaleOrderItem
Context module: CaHeoShop.Sales
Relationship fields: customer_id, sale_order_id, product_variant_id
```

Prefer `CaHeoShop.Sales` over `Orders` or `Commerce` because it can own the sale order workflow without becoming a broad ecommerce catch-all. If the app later needs quotes, invoices, or payments as separate domains, this can be revisited.

## 17. Recommended Migration Shape

Documentation-only example:

```elixir
create table(:sale_orders) do
  add :order_number, :string, null: false
  add :customer_id, references(:users, on_delete: :restrict), null: false

  add :status, :string, null: false, default: "pending"
  add :payment_status, :string, null: false, default: "unpaid"
  add :fulfillment_status, :string, null: false, default: "unfulfilled"

  add :subtotal_amount, :integer, null: false, default: 0
  add :shipping_fee, :integer, null: false, default: 0
  add :discount_amount, :integer, null: false, default: 0
  add :total_amount, :integer, null: false, default: 0

  add :customer_name, :string, null: false
  add :customer_email, :string, null: false
  add :customer_phone, :string, null: false

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
create index(:sale_orders, [:status])
create index(:sale_orders, [:payment_status])
create index(:sale_orders, [:fulfillment_status])
create index(:sale_orders, [:inserted_at])

create constraint(:sale_orders, :subtotal_amount_non_negative,
         check: "subtotal_amount >= 0")

create constraint(:sale_orders, :shipping_fee_non_negative,
         check: "shipping_fee >= 0")

create constraint(:sale_orders, :discount_amount_non_negative,
         check: "discount_amount >= 0")

create constraint(:sale_orders, :total_amount_non_negative,
         check: "total_amount >= 0")
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

create constraint(:sale_order_items, :quantity_positive,
         check: "quantity > 0")

create constraint(:sale_order_items, :unit_price_snapshot_non_negative,
         check: "unit_price_snapshot >= 0")

create constraint(:sale_order_items, :production_cost_snapshot_non_negative,
         check: "production_cost_snapshot >= 0")

create constraint(:sale_order_items, :line_total_amount_non_negative,
         check: "line_total_amount >= 0")
```

These samples should be treated as proposals only.

## 18. Optional or Deferred Fields

### `recipient_id`

Defer. Task 011 is expected to research saved recipients. Orders should snapshot recipient data even if a future `recipient_id` is added.

### `cart_id`

Defer. Current cart research recommends line-item-only carts without a durable cart header.

### `currency`

Defer. The project is Vietnam-focused and prices are VND integer amounts.

### `paid_at`

Defer until real payment confirmation exists. Payment status is enough for the first order schema.

### `shipping_provider`, `tracking_number`, `shipped_at`, `delivered_at`

Defer. The current UI does not support shipment management yet.

### `tax_amount`

Defer. No tax workflow exists in current UI or requirements.

### `coupon_id`, `discount_code`

Defer. Keep only `discount_amount` as a numeric snapshot if discounts are manually applied later.

### `status_history`

Defer. Add an order events table later if audit trails become necessary.

## 19. Open Questions

- Should the first real checkout require authentication, or should guest checkout be designed before implementation?
- Should `customer_name` and `customer_phone` always mirror recipient fields in the first UI, or should checkout collect separate buyer and recipient data?
- Should `payment_method` default to `manual`, `bank_transfer`, or remain nullable until payment UI is designed?
- Should order numbers use a date prefix, sequential number, or another generated format?
- Should product and variant deletion be replaced by archive/status fields before real order tables are implemented?
- Should a future order detail route expose `sale_order_items` to customers and admins?

## 20. Final Recommendation

For the first implementation, create:

```text
sale_orders
sale_order_items
```

Recommended core shape:

```text
sale_orders
- order_number
- customer_id
- status
- payment_status
- fulfillment_status
- subtotal_amount
- shipping_fee
- discount_amount
- total_amount
- customer_name
- customer_email
- customer_phone
- recipient_fullname
- recipient_phone_number
- recipient_address
- payment_method
- payment_reference
- customer_note
- admin_note
- confirmed_at
- cancelled_at
- completed_at
```

```text
sale_order_items
- sale_order_id
- product_variant_id
- product_name_snapshot
- product_slug_snapshot
- variant_name_snapshot
- unit_price_snapshot
- production_cost_snapshot
- quantity
- line_total_amount
- image_filename_snapshot
```

Recommended modules:

```text
Schema:  CaHeoShop.Sales.SaleOrder
Schema:  CaHeoShop.Sales.SaleOrderItem
Context: CaHeoShop.Sales
```

Use `product_variant_id` for order items because the variant is the selected sellable option. Snapshot product, variant, price, cost, and line total data so historical orders remain accurate after product catalog changes.
