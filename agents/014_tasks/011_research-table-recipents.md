# Task 011: Research Recipients Database Schema

## Objective

Research the current customer, checkout, account settings, and sale order flow, then propose a database schema for storing customer recipients and delivery addresses.

The expected output is a research document:

```text
research/014_table-recipents.md
```

This task is for research and database design proposal only.

Do not create migrations, Ecto schemas, Ecto contexts, or real recipient/address behavior in this task.

---

## Deliverable

Create the following file:

```text
research/014_table-recipents.md
```

The document should describe the proposed database schema for customer recipients based on:

* Current customer/account UI
* Current checkout UI
* Current sale order research
* Existing user/authentication model
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
tasks/007-research-current-database-model.md
tasks/010-research-table-sale-orders.md
```

Also read these research files if they exist:

```text
research/012-table-carts.md
research/013_table-sale-orders.md
```

Inspect current code related to:

```text
/account
/account/settings
/checkout
/orders
/admin/customers
/admin/orders
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
* Real recipient CRUD behavior
* Real checkout behavior
* Real order creation behavior

The goal is to produce a database design proposal that can be reviewed before implementation.

---

## Table To Research

Research a table for storing customer recipients.

The requested table/file naming uses:

```text
recipents
```

Important naming note:

The word `recipent` appears to be a misspelling of `recipient`.

During research, evaluate whether the final database table and field names should use the correct spelling:

```text
recipients
recipient_name
recipient_address
recipient_phone_number
```

or keep the requested spelling:

```text
recipents
recipent_name
recipent_address
recipent_phone_number
```

The research document should make a clear recommendation before implementation.

The deliverable filename must remain:

```text
research/014_table-recipents.md
```

---

## Known Business Meaning

Each customer can have multiple recipients.

A recipient represents a saved delivery contact/address that can be reused during checkout.

Examples:

* Customer orders for themselves
* Customer sends goods to a family member
* Customer sends goods to a friend
* Customer has multiple delivery addresses

Expected relationship:

```text
Customer has many Recipients
Recipient belongs to Customer
```

---

## Known Basic Fields

At minimum, research these fields:

```text
customer_id
recipent_name
recipent_address
recipent_phone_number
```

Also evaluate the corrected spelling version:

```text
customer_id
recipient_name
recipient_address
recipient_phone_number
```

---

## Areas To Research

### Customer / User Relationship

Inspect the existing authentication model.

Research whether `customer_id` should reference:

```text
users.id
```

or whether a separate future `customers` table is needed.

For the first implementation, prefer the simplest approach that fits the current authentication model.

The research document should explain:

* Whether current users represent customers
* Whether `customer_id` should be named `user_id`
* Tradeoffs between `customer_id` and `user_id`
* Whether guest checkout recipients should be deferred

---

### Checkout Usage

Inspect the checkout page.

Research:

* Whether checkout asks for recipient name
* Whether checkout asks for recipient phone number
* Whether checkout asks for recipient address
* Whether user can select a saved recipient
* Whether user can enter a one-time recipient address
* Whether checkout currently uses mock data only

Document what fields the checkout UI implies.

---

### Account Settings Usage

Inspect account/settings UI.

Research:

* Whether customers can manage saved addresses
* Whether customers can add/edit/delete recipients
* Whether there is a default recipient/address
* Whether address management is currently mock data only

Document what fields account UI needs.

---

### Sale Order Relationship

Review sale order research.

Research how recipients relate to sale orders.

Questions to answer:

* Should `sale_orders` copy recipient information at order time?
* Should `sale_orders` reference a recipient row?
* Should both be done?
* What happens if the customer edits or deletes a recipient after placing an order?

Recommended direction to evaluate:

```text
sale_orders should snapshot recipient information at order time.
sale_orders may optionally reference the selected recipient_id.
```

This preserves historical order data even if the saved recipient changes later.

---

## Fields To Evaluate

The research document should evaluate whether these fields are needed for the first version.

### Required Candidate Fields

Evaluate:

```text
id
customer_id
recipient_name
recipient_address
recipient_phone_number
inserted_at
updated_at
```

Also discuss the user-provided spelling:

```text
recipent_name
recipent_address
recipent_phone_number
```

and recommend final naming.

---

### Optional or Deferred Fields

Evaluate whether these fields are needed now or later:

```text
label
is_default
address_line1
address_line2
ward
district
city
province
country
note
deleted_at
last_used_at
```

Do not add fields blindly.

For each proposed field, explain:

* Purpose
* Type
* Required or optional
* Default value if any
* Whether it is needed now or can be deferred

---

## Address Modeling Question

Research whether the first implementation should use:

```text
Option A:
recipient_address as one text field
```

or:

```text
Option B:
split address into ward, district, city, province, address_line1, address_line2
```

For the first implementation, prefer the simplest model unless current UI clearly requires structured address fields.

The document should explain the tradeoff.

---

## Proposed Schema Content

The research document should propose a first version of the recipients table.

At minimum, evaluate:

```text
id
customer_id
recipient_name
recipient_address
recipient_phone_number
inserted_at
updated_at
```

If the research recommends keeping the requested misspelled names, explain why.

If the research recommends corrected spelling, provide a clear final recommendation.

---

## Indexes and Constraints

The research document should recommend database constraints and indexes.

Evaluate:

```text
foreign key from recipients.customer_id to users.id
index on customer_id
not null constraints
phone number format expectations
default recipient uniqueness per customer if is_default is added later
```

Also document tradeoffs.

---

## Naming Recommendation

Recommend final naming for:

```text
Table name
Schema module
Context module
Relationship fields
Route usage
```

Examples to evaluate:

```text
recipients
CaHeoShop.Customers.Recipient
CaHeoShop.Customers
recipients.customer_id
```

Also evaluate whether this belongs under:

```text
Accounts
Customers
Sales
Commerce
```

Prefer simple and clear naming.

Do not implement naming changes in this task.

---

## Expected Output Structure

The file `research/014_table-recipents.md` should contain:

1. Overview
2. Current UI Findings
3. Customer/User Relationship Analysis
4. Checkout Recipient Requirements
5. Account Recipient Management Requirements
6. Sale Order Relationship Analysis
7. Naming and Spelling Recommendation
8. Proposed Recipients Table
9. Field-by-Field Explanation
10. Address Modeling Recommendation
11. Indexes and Constraints
12. Recommended Ecto Schema Shape
13. Recommended Migration Shape
14. Optional or Deferred Fields
15. Open Questions
16. Final Recommendation

---

## Recommended Migration Shape

The research document may include a sample migration shape as documentation only.

Do not create the actual migration file.

Recommended corrected spelling example:

```elixir
create table(:recipients) do
  add :customer_id, references(:users, on_delete: :delete_all), null: false

  add :recipient_name, :string, null: false
  add :recipient_address, :text, null: false
  add :recipient_phone_number, :string, null: false

  timestamps(type: :utc_datetime)
end

create index(:recipients, [:customer_id])
```

If the research recommends keeping the requested spelling, provide the alternative migration shape as documentation only.

These samples should be treated as proposals, not implementation.

---

## Research Guidance

During research, if additional fields appear necessary from the UI or business workflow, add them to the proposal.

However:

* Do not add fields just because ecommerce platforms usually have them.
* Keep the first implementation simple.
* Clearly separate required fields from deferred fields.
* Explain why each extra field is recommended.
* Do not design a full address book system unless clearly needed.
* Do not implement recipient CRUD behavior.
* Do not implement checkout behavior.
* Do not implement order creation behavior.

---

## Success Criteria

The task is complete when:

* `research/014_table-recipents.md` is created.
* The document is based on current UI and mock data observations.
* The known recipient requirements are addressed.
* The customer/user relationship is clearly explained.
* The relationship between recipients and sale orders is clearly explained.
* The document evaluates the spelling issue between `recipent` and `recipient`.
* Required fields are identified.
* Optional or deferred fields are separated from required fields.
* Address modeling tradeoffs are explained.
* Indexes and constraints are recommended.
* Open questions are documented.
* No database migration is created.
* No Ecto schema is created.
* No Ecto context is created.
* No Repo queries are added.
* No real recipient CRUD behavior is implemented.
* No real checkout behavior is implemented.
* No real order creation behavior is implemented.
* No production code is changed unless needed only to inspect references.
