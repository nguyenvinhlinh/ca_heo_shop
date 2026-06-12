# Task 012: Research Store Settings Database Schema

## Objective

Research the current admin settings UI and business requirements, then propose a database schema for storing global store settings.

The expected output is a research document:

```text
research/015_table-store-settings.md
```

This task is for research and database design proposal only.

Do not create migrations, Ecto schemas, Ecto contexts, or real settings persistence in this task.

---

## Deliverable

Create the following file:

```text
research/015_table-store-settings.md
```

The document should describe the proposed database schema for `store_settings` based on:

* Current `/admin/settings` UI
* Storefront business needs
* Payment display needs
* Contact information needs
* Shipping and announcement needs
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
tasks/005-admin-skeleton.md
tasks/005-02-enhance-admin-settings.md
```

Use `research/004-commerce-order-flow.md` as the primary source for checkout/payment display boundaries:

```text
store_settings may provide payment and shipping instructions
payment_procedures own payment workflow status
financial_transactions own actual money movement records
store_settings must not store order-specific payment state
```

Also inspect current code related to:

```text
/admin/settings
/
 /checkout
/cart
lib/**/settings*
lib/**/*settings*
priv/repo/migrations
```

If some routes or files do not exist yet, document that clearly.

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
* Real settings persistence
* Real payment behavior
* Real checkout behavior

The goal is to produce a database design proposal that can be reviewed before implementation.

---

## Table To Research

Research a table for global store settings.

Proposed table name:

```text
store_settings
```

This table should store configuration that belongs to the store itself, not to a user, product, cart, or order.

---

## Known Business Meaning

`store_settings` represents editable configuration for the shop.

Possible examples:

```text
store name
store tagline
contact email
contact phone
store address
shipping note
payment note
general payment instructions
announcement text
maintenance mode flag
```

However, do not add fields blindly.

Only recommend fields that are useful for the current or near-future UI.

---

## Important Design Question

Research whether the first implementation should use:

```text
Option A:
A single-row store_settings table with explicit columns.
```

Example:

```text
store_settings
- id
- store_name
- contact_email
- contact_phone
- payment_note
- shipping_note
- inserted_at
- updated_at
```

or:

```text
Option B:
A key-value settings table.
```

Example:

```text
store_settings
- id
- key
- value
- value_type
- inserted_at
- updated_at
```

The research document should evaluate both options.

For the first implementation, prefer the simplest approach that fits the current admin UI.

---

## Areas To Research

### Admin Settings Usage

Inspect `/admin/settings`.

Research:

* What settings sections currently exist
* What settings sections were removed by previous tasks
* What settings are still visible
* Whether settings are mock-only
* Whether there are forms, toggles, or placeholders
* Which settings are truly needed soon

Document what fields the admin UI implies.

---

### Storefront Usage

Inspect storefront pages.

Research whether store settings may be used for:

* Store name
* Footer contact information
* Announcement banner
* Store description
* Social links
* Customer support information

Document which fields are useful for customer-facing pages.

---

### Checkout Usage

Inspect cart and checkout pages.

Research whether store settings may be used for:

* Shipping note
* Payment note
* General bank transfer instruction text
* General QR payment instruction text
* COD availability
* Customer support phone number

Do not implement payment logic in this task.

Only document schema implications for reusable display copy.

Do not store order-specific payment status, payment confirmation, payment reference, refund status, or financial ledger data in `store_settings`. Those belong to future `payment_procedures` and `financial_transactions`.

---

## Fields To Evaluate

The research document should evaluate whether these fields are needed for the first version.

### Store Identity Fields

Evaluate:

```text
store_name
store_tagline
store_description
logo_filename
```

Important note:

Previous task `005-02` removed the old `Store information` section from `/admin/settings`.

Do not assume those fields must be implemented now.

Only recommend them if the current or near-future UI clearly needs them.

---

### Contact Fields

Evaluate:

```text
contact_email
contact_phone
contact_address
support_note
```

---

### Payment Fields

Evaluate:

```text
payment_note
```

The project may use QR code, cash, COD, or manual bank transfer later.

Detailed bank account fields and QR payment image storage should be deferred unless the current admin settings UI explicitly needs structured payment display fields.

Deferred examples:

```text
bank_account_name
bank_account_number
bank_name
qr_payment_image_filename
cod_enabled
cash_enabled
```

Do not implement payment confirmation logic in this task.

---

### Shipping Fields

Evaluate:

```text
shipping_note
default_shipping_fee
free_shipping_threshold
```

Keep this simple.

Do not design a full shipping provider system.

---

### Storefront Display Fields

Evaluate:

```text
announcement_text
announcement_enabled
maintenance_mode_enabled
```

Only recommend these if they are useful for current storefront behavior.

---

### Metadata Fields

Evaluate:

```text
inserted_at
updated_at
```

Also evaluate whether these are useful:

```text
updated_by_id
```

Do not add audit fields unless there is a clear need.

---

## Proposed Schema Content

The research document should propose a first version of the `store_settings` schema.

At minimum, evaluate:

```text
id
contact_email
contact_phone
payment_note
shipping_note
inserted_at
updated_at
```

Also evaluate whether these fields are needed now or later:

```text
store_name
store_tagline
store_description
logo_filename
contact_address
bank_account_name
bank_account_number
bank_name
qr_payment_image_filename
cod_enabled
cash_enabled
default_shipping_fee
free_shipping_threshold
announcement_text
announcement_enabled
maintenance_mode_enabled
updated_by_id
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

Evaluate:

```text
single-row constraint strategy
unique key constraint if using key-value settings
not null constraints
money amount constraints
boolean defaults
```

If using a single-row table, explain how the app should ensure only one settings row exists.

If using a key-value table, explain how keys should be validated.

---

## Naming Recommendation

Recommend final naming for:

```text
Table name
Schema module
Context module
Route usage
```

Examples to evaluate:

```text
store_settings
CaHeoShop.StoreSettings.StoreSetting
CaHeoShop.StoreSettings
```

Also evaluate whether this belongs under:

```text
Settings
Store
Commerce
Admin
```

Prefer simple and clear naming.

Do not implement naming changes in this task.

---

## Expected Output Structure

The file `research/015_table-store-settings.md` should contain:

1. Overview
2. Current Admin Settings Findings
3. Storefront Usage Requirements
4. Checkout and Payment Display Requirements
5. Schema Design Options
6. Proposed `store_settings` Table
7. Field-by-Field Explanation
8. Single-Row vs Key-Value Recommendation
9. Indexes and Constraints
10. Recommended Ecto Schema Shape
11. Recommended Migration Shape
12. Optional or Deferred Fields
13. Open Questions
14. Final Recommendation

---

## Recommended Migration Shape

The research document may include sample migration shapes as documentation only.

Do not create the actual migration file.

Example single-row table proposal:

```elixir
create table(:store_settings) do
  add :contact_email, :string
  add :contact_phone, :string
  add :payment_note, :text
  add :shipping_note, :text

  timestamps(type: :utc_datetime)
end
```

Example key-value table proposal:

```elixir
create table(:store_settings) do
  add :key, :string, null: false
  add :value, :text
  add :value_type, :string, null: false, default: "string"

  timestamps(type: :utc_datetime)
end

create unique_index(:store_settings, [:key])
```

These samples should be treated as proposals, not implementation.

The final research document may recommend a smaller or different schema if research supports it.

---

## Research Guidance

During research, if additional fields appear necessary from the UI or business workflow, add them to the proposal.

However:

* Do not add fields just because ecommerce platforms usually have them.
* Keep the first implementation simple.
* Clearly separate required fields from deferred fields.
* Explain why each extra field is recommended.
* Do not design a full CMS.
* Do not design a full payment gateway integration.
* Do not design a full shipping provider integration.
* Do not implement settings persistence.

---

## Success Criteria

The task is complete when:

* `research/015_table-store-settings.md` is created.
* The document is based on current UI and mock data observations.
* The proposed `store_settings` table is documented.
* The document evaluates single-row settings versus key-value settings.
* Required fields are identified.
* Optional or deferred fields are separated from required fields.
* Storefront usage is documented.
* Checkout/payment display usage is documented.
* Indexes and constraints are recommended.
* Open questions are documented.
* No database migration is created.
* No Ecto schema is created.
* No Ecto context is created.
* No Repo queries are added.
* No real settings persistence is implemented.
* No production code is changed unless needed only to inspect references.
