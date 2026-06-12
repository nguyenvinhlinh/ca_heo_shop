# Recipients Table Research

## 1. Overview

This document proposes the first database shape for saved delivery recipients and addresses.

The original task and deliverable filename used the spelling `recipents`, but the correct English spelling is `recipients`. This document uses the corrected filename:

```text
research/014_table-recipients.md
```

For database tables, fields, schema modules, and context naming, this document recommends the correct spelling:

```text
recipients
name
address
phone_number
is_default
```

The current checkout, account, account settings, orders, admin customers, and admin orders pages are mock-only. There is no real recipient CRUD, checkout persistence, order creation, or address management yet.

This task is research only. The examples below are proposals, not implemented migrations, Ecto schemas, contexts, Repo queries, seeds, tests, recipient CRUD, checkout behavior, or order creation.

## 2. Current UI Findings

Current related routes:

- `/checkout`
- `/account`
- `/account/settings`
- `/orders`
- `/admin/customers`
- `/admin/orders`

Route placement:

- Storefront/account routes are inside the existing `:current_user` LiveView session and `:browser` pipeline because they work with or without authentication.
- Admin routes are inside the existing `:require_authenticated_user` LiveView session and authenticated browser scope because they are administrator workflows.

Current application tables:

```text
users
users_tokens
```

There are no current business persistence tables for recipients, carts, sale orders, products, or customers.

Current checkout page:

- asks for customer full name
- asks for customer phone
- asks for customer email
- asks for address
- asks for city
- asks for order note
- does not let users select a saved recipient
- does not let users save a recipient
- does not submit real checkout data

Current account page:

- shows a mock profile summary
- shows one address placeholder
- shows recent order placeholders
- does not list saved recipients

Current account settings page:

- shows placeholder profile/password/address cards
- has an "Edit address" placeholder button
- does not create, edit, delete, or default saved recipients

Current admin customers page:

- shows mock customer name, email, phone, order count, last order, and location
- does not show saved recipients or addresses

Current admin orders page:

- shows mock order number, customer, email, status, total, and created date
- does not show recipient detail yet

## 3. Customer/User Relationship Analysis

There is no separate `customers` table yet. The current `users` table is the only persisted buyer identity available.

Recommended first relationship:

```text
recipients.customer_id -> users.id
```

Use the column name `customer_id` because a recipient belongs to a customer in the ecommerce workflow. In Ecto this can still point to `CaHeoShop.Accounts.User`:

```elixir
belongs_to :customer, CaHeoShop.Accounts.User, foreign_key: :customer_id
```

Tradeoff:

- `user_id` is technically clearer because it references `users.id`.
- `customer_id` is business clearer because saved recipients are customer-owned delivery records.

For the first implementation, prefer `customer_id` referencing `users.id`. Guest checkout recipients should be deferred because guest recipient storage requires session identity, expiration, merge-on-login behavior, and privacy rules.

Use `on_delete: :delete_all` for `customer_id` in the first recipients table because saved recipients are reusable account data, not historical order records. Historical sale orders should snapshot recipient data separately and should not depend on recipient rows staying present.

## 4. Checkout Recipient Requirements

The current checkout UI implies these recipient-related values:

```text
name or customer full name
phone_number or customer phone
address composed from address and city inputs
```

The UI does not currently distinguish buyer contact from delivery recipient. For the first saved recipient design, keep one reusable recipient contact/address record:

```text
name
phone_number
address
is_default
```

Future checkout can support:

- selecting an existing recipient
- entering a one-time recipient
- saving a new recipient for reuse
- using saved recipient data to prefill checkout fields

Do not implement those behaviors in this task.

## 5. Account Recipient Management Requirements

The current `/account/settings` page has only an address placeholder. It does not support:

- recipient list
- add recipient
- edit recipient
- delete recipient
- default recipient selection
- multiple addresses

Schema implications:

- A simple `recipients` table is enough for future saved address CRUD.
- `is_default` should be included now so checkout/account UI can identify the preferred delivery address later without another table redesign.
- Structured address fields can be deferred because current UI only exposes a free-form address and city.

## 6. Sale Order Relationship Analysis

Sale order research recommends snapshotting recipient fields directly on `sale_orders`:

```text
sale_orders.recipient_fullname
sale_orders.recipient_phone_number
sale_orders.recipient_address
```

That remains the correct historical order behavior. If a customer edits or deletes a saved recipient after placing an order, the placed order must still show the original recipient information.

Recommended first relationship:

- `recipients` stores reusable customer address book entries.
- `sale_orders` copies recipient information at order creation.
- `sale_orders.recipient_id` should be deferred until saved recipient selection exists in checkout.

If `recipient_id` is added later to `sale_orders`, it should be optional and used only as provenance. The snapshots should remain the source of historical order display.

## 7. Naming and Spelling Recommendation

Use corrected spelling for implementation:

```text
Table: recipients
Fields: name, address, phone_number, is_default
```

Do not use misspelled database names or column names. In particular, do not introduce columns using the misspelled prefix.

```text
recipents
```

Reasoning:

- misspelled table and field names become long-term technical debt
- corrected names match sale order research fields like `recipient_fullname`
- corrected names are easier for future developers and admin UI labels
- the task already asks to evaluate and likely recommend corrected spelling

The old misspelled filename should not be used for future implementation references.

## 8. Proposed Recipients Table

Recommended first fields:

```text
id
customer_id
name
address
phone_number
is_default
inserted_at
updated_at
```

Recommended first table meaning:

```text
recipients = reusable delivery contacts/addresses owned by customers
```

Each recipient row represents one saved delivery contact and address that a customer can reuse during checkout later.

## 9. Field-by-Field Explanation

### `id`

- Type: primary key
- Required: yes
- Default: generated by database
- Needed now: yes
- Purpose: stable recipient identity

### `customer_id`

- Type: foreign key to `users.id`
- Required: yes
- Default: none
- Needed now: yes
- Purpose: owner of the saved recipient

Recommended relationship:

```text
recipients.customer_id -> users.id
```

### `name`

- Type: string
- Required: yes
- Default: none
- Needed now: yes
- Purpose: delivery recipient's display name

Use `name` for the saved recipient table. Sale orders can use `recipient_fullname` to make historical checkout snapshots clearer.

### `address`

- Type: text column in migration, `:string` field in Ecto schema
- Required: yes
- Default: none
- Needed now: yes
- Purpose: free-form delivery address

Use a single text field for the first version because the current checkout UI is simple and does not require structured address search or shipping-rate calculations.

### `phone_number`

- Type: string
- Required: yes
- Default: none
- Needed now: yes
- Purpose: delivery contact phone number

Store phone numbers as strings, not integers. Phone numbers can contain leading zeroes, spaces, and country prefixes.

### `is_default`

- Type: boolean
- Required: yes
- Default: `false`
- Needed now: yes
- Purpose: marks the customer's preferred saved recipient/address

Use `is_default` so checkout can later preselect one saved recipient. A partial unique index should enforce at most one default recipient per customer.

### `inserted_at`

- Type: UTC datetime timestamp
- Required: yes
- Default: generated by Ecto timestamps
- Needed now: yes
- Purpose: track when the saved recipient was created

### `updated_at`

- Type: UTC datetime timestamp
- Required: yes
- Default: generated by Ecto timestamps
- Needed now: yes
- Purpose: track edits to recipient name, phone, or address

## 10. Address Modeling Recommendation

Recommended first model:

```text
address as one text field
```

Benefits:

- matches current checkout/account placeholder UI
- easiest for a small owner-operated shop
- works well for manual local delivery confirmation
- avoids premature address validation complexity

Deferred structured model:

```text
address_line1
address_line2
ward
district
city
province
country
```

Structured address fields are useful later for shipping-rate calculation, region filtering, carrier integrations, or more precise delivery workflows. They are not needed by the current mock UI.

## 11. Indexes and Constraints

Recommended constraints:

- `customer_id` not null
- `name` not null
- `address` not null
- `phone_number` not null
- `is_default` not null, default `false`

Recommended foreign key:

```text
recipients.customer_id -> users.id
```

Recommended delete behavior:

```elixir
references(:users, on_delete: :delete_all)
```

Recommended indexes:

```elixir
create index(:recipients, [:customer_id])
create unique_index(:recipients, [:customer_id],
         where: "is_default = true",
         name: :recipients_one_default_per_customer_index)
```

Phone number validation should be handled in changesets first. Do not add a strict database phone format constraint yet because valid Vietnamese phone formats, spacing, and optional country codes need product decisions.

Do not add a uniqueness constraint on phone or address. Multiple customers can share the same phone or address, and one customer may intentionally save similar recipients.

The partial unique index keeps `is_default` useful without forcing every customer to have a default recipient.

## 12. Recommended Ecto Schema Shape

Documentation-only example:

```elixir
schema "recipients" do
  belongs_to :customer, CaHeoShop.Accounts.User, foreign_key: :customer_id

  field :name, :string
  field :address, :string
  field :phone_number, :string
  field :is_default, :boolean, default: false

  timestamps(type: :utc_datetime)
end
```

Recommended naming:

```text
Table name: recipients
Schema module: CaHeoShop.Customers.Recipient
Context module: CaHeoShop.Customers
Relationship fields:
  customer_id
```

Prefer `CaHeoShop.Customers` over `Accounts`, `Sales`, or `Commerce`:

- `Accounts` should remain focused on authentication and login identity.
- `Sales` should own order creation and order history.
- `Commerce` is too broad for the current small app.
- `Customers` can own customer profile-adjacent data such as recipients later.

## 13. Recommended Migration Shape

Documentation-only example:

```elixir
create table(:recipients) do
  add :customer_id, references(:users, on_delete: :delete_all), null: false

  add :name, :string, null: false
  add :address, :text, null: false
  add :phone_number, :string, null: false
  add :is_default, :boolean, null: false, default: false

  timestamps(type: :utc_datetime)
end

create index(:recipients, [:customer_id])
create unique_index(:recipients, [:customer_id],
         where: "is_default = true",
         name: :recipients_one_default_per_customer_index)
```

Do not include misspelled recipient columns in implementation.

## 14. Optional or Deferred Fields

### `label`

Defer. Useful for labels such as "Home", "Office", or "Mom", but current UI does not show recipient labels.

### `address_line1`, `address_line2`, `ward`, `district`, `city`, `province`, `country`

Defer. Use one `address` text field first.

### `note`

Defer. Delivery notes can be captured on `sale_orders.customer_note` first. Add recipient-level notes later if customers need reusable delivery instructions.

### `deleted_at`

Defer. Soft deletion can be added later if recipient history or recovery matters. Sale orders already snapshot recipient details, so hard deletion of saved recipients is acceptable for the first version.

### `last_used_at`

Defer. Useful for sorting saved recipients by recent use, but no recipient selection UI exists yet.

### `recipient_fullname`

Do not use on `recipients` for the first version. Use `name` for saved recipient records and keep `recipient_fullname` on `sale_orders` as the checkout snapshot field.

## 15. Open Questions

- Should checkout require login before saved recipients can be used?
- Should the first recipient CRUD UI live under `/account/settings` or a dedicated `/account/recipients` route?
- Should the app support one default recipient in the first recipient UI?
- Should future sale orders store optional `recipient_id` as provenance in addition to recipient snapshots?
- Should phone validation require Vietnamese mobile formats only, or allow international numbers?
- Should structured city/province fields be introduced before shipping integrations?

## 16. Final Recommendation

For the first implementation, create a simple saved recipients table with corrected spelling:

```text
recipients
- customer_id
- name
- address
- phone_number
- is_default
```

Recommended modules:

```text
Schema:  CaHeoShop.Customers.Recipient
Context: CaHeoShop.Customers
```

Recommended relationship:

```text
recipients.customer_id -> users.id
```

Recommended migration shape:

```elixir
create table(:recipients) do
  add :customer_id, references(:users, on_delete: :delete_all), null: false
  add :name, :string, null: false
  add :address, :text, null: false
  add :phone_number, :string, null: false
  add :is_default, :boolean, null: false, default: false

  timestamps(type: :utc_datetime)
end

create index(:recipients, [:customer_id])
create unique_index(:recipients, [:customer_id],
         where: "is_default = true",
         name: :recipients_one_default_per_customer_index)
```

Sale orders should continue to snapshot recipient information at order creation. A future optional `sale_orders.recipient_id` can be added after checkout supports selecting saved recipients.
