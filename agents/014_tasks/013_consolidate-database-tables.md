# Task 013: Consolidate Database Model Documentation

## Objective

After completing the database research tasks, consolidate all database table research into the main database model document:

```text
agents/012_database-model.md
```

This task updates documentation only.

Do not create migrations, Ecto schemas, Ecto contexts, Repo queries, or production database behavior.

---

## Context

Previous tasks researched individual database tables for the project.

The goal of this task is to read the completed task files and their expected research outputs, then update `agents/012_database-model.md` so future agents have one clear database reference.

This document should distinguish between:

```text
Currently implemented database tables
```

and:

```text
Proposed / researched future business tables
```

Do not present proposed tables as already implemented.

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
```

Also inspect the task files related to database research.

At minimum, inspect relevant files under:

```text
tasks/
```

Look for tasks related to:

```text
collections
products
product_variants
product_images
carts
sale_orders
sale_order_items
recipients
store_settings
current database model
```

The user expects this task to rely on the completed research from tasks such as:

```text
Task 007
Task 008
Task 009
Task 010
Task 012
```

If task numbering differs in the repository, follow the actual task files and their content.

---

## Research Files To Read

Read all available database research files.

Expected research files may include:

```text
research/010_table-collections.md
research/011-table-products-product-images.md
research/012-table-carts.md
research/013_table-sale-orders.md
research/014_table-recipents.md
research/015_table-store-settings.md
```

Some files may not exist depending on completed tasks.

If a file is missing, document it clearly in the updated database model.

Do not invent content for missing research files.

---

## Current Database Inspection

Inspect the actual current database implementation from:

```text
priv/repo/migrations
lib/**/accounts
lib/**/*user*
```

Document currently implemented application tables.

Known current tables may include:

```text
users
user_tokens
```

Ignore system/internal migration tracking table:

```text
schema_migrations
```

If the actual implemented tables differ, document the real current state.

---

## Core Rule

This is a documentation consolidation task only.

Do not create, modify, or run:

* New database migrations
* New Ecto schemas
* New Ecto contexts
* Repo queries
* Seeds
* Tests
* Real CRUD behavior
* Real cart behavior
* Real checkout behavior
* Real order behavior
* Real settings persistence

Do not change production code.

Only update:

```text
agents/012_database-model.md
```

---

## File To Update

Update:

```text
agents/012_database-model.md
```

If the file exists, replace or restructure it as needed.

If the file does not exist, create it.

The document should become the main database model reference for the project.

---

## Required Document Structure

Update `agents/012_database-model.md` with this structure:

```text
# Database Model

## Overview

## Current Database Status

## Implemented Tables

## Proposed Business Tables

## Table Summary

## Relationships Overview

## Authentication Tables

## Catalog Tables

## Cart Tables

## Sales / Order Tables

## Customer Recipient Tables

## Store Settings Tables

## Deferred / Future Tables

## Research References

## Open Questions
```

You may adjust heading names slightly if needed, but keep the document easy for future agents to scan.

---

## Current Database Status

Document that the database is still in an early stage.

The current implemented database should be documented separately from proposed tables.

Example wording:

```text
The current database only contains authentication-related tables.
Business tables such as collections, products, carts, sale orders, recipients, and store settings are research proposals unless implemented later.
```

Only state this if it matches the actual codebase after inspection.

---

## Implemented Tables Section

Document actual implemented application tables.

Known implemented tables may include:

```text
users
user_tokens
```

For each implemented table, include:

* Table name
* Related Ecto schema module
* Related context module
* Purpose
* Important fields
* Important indexes / constraints
* Relationships

Ignore:

```text
schema_migrations
```

---

## Proposed Business Tables Section

Summarize all researched proposed tables.

Expected proposed tables may include:

```text
collections
products
product_variants
product_images
carts
sale_orders
sale_order_items
recipients
store_settings
```

Only include a table as proposed if the related research file exists or the task file clearly defines it.

For each proposed table, include:

* Table name
* Proposed schema module
* Proposed context module
* Purpose
* Core fields
* Important relationships
* Important constraints
* Source research file

Keep this section concise.

Do not copy the full research files into `agents/012_database-model.md`.

This document should be a practical summary, not a full research archive.

---

## Table Summary

Create a compact table summary.

Suggested columns:

```text
Table
Status
Purpose
Related Research
```

Example statuses:

```text
Implemented
Proposed
Deferred
Open Question
```

Use `Implemented` only for tables that actually exist in migrations/schemas.

Use `Proposed` for tables that are researched but not implemented.

---

## Relationships Overview

Summarize important relationships from the research.

Expected relationships may include:

```text
User has many UserTokens

Collection has many Products
Product belongs to Collection

Product has many ProductVariants
ProductVariant belongs to Product

Product has many ProductImages
ProductImage belongs to Product

User/Customer has many Cart rows
Cart row belongs to User/Customer
Cart row belongs to ProductVariant or Product depending on research recommendation

User/Customer has many SaleOrders
SaleOrder has many SaleOrderItems
SaleOrderItem belongs to ProductVariant or Product depending on research recommendation

User/Customer has many Recipients
Recipient belongs to User/Customer
```

Important:

If research recommends `product_variant_id` for carts or sale order items, document that clearly.

If research is still undecided, mark it as an open question.

---

## Catalog Tables

Summarize catalog-related proposed tables:

```text
collections
products
product_variants
product_images
```

Document important decisions from research, especially:

* Product belongs to one collection
* Product has bilingual names
* Product uses slug
* Product variants are simple combined values such as `PLA Red`
* Variant has price, production cost, stock quantity, and image filename
* Product images are general gallery images
* Variant image filename is used for variant-specific preview image

Do not over-expand.

---

## Cart Tables

Summarize cart research.

Expected table:

```text
carts
```

Document:

* Customer/user relationship
* Product or variant relationship
* Quantity
* Whether `customer_id` should reference `users.id`
* Whether cart rows should reference `product_id` or `product_variant_id`

If the product variant research affects the cart model, mention that the database model should prefer the sellable item reference.

---

## Sales / Order Tables

Summarize sale order research.

Expected tables:

```text
sale_orders
sale_order_items
```

Document:

* Sale order header
* Sale order item lines
* Recipient snapshot fields
* Status fields
* Payment status
* Fulfillment status
* Money fields stored as integer VND
* Product or variant snapshot strategy
* Cart-to-order conversion concept

Important:

If research recommends snapshotting product or variant name and price into `sale_order_items`, document that clearly.

---

## Customer Recipient Tables

Summarize recipient research.

Expected table may be:

```text
recipients
```

Important spelling note:

If the research file is named:

```text
research/014_table-recipents.md
```

still evaluate the final table naming recommendation from the research.

The final database model should prefer correct spelling if research recommends it:

```text
recipients
recipient_name
recipient_address
recipient_phone_number
```

Do not blindly preserve misspelled database names unless the research explicitly recommends doing so.

---

## Store Settings Tables

Summarize store settings research.

Expected table:

```text
store_settings
```

Document whether research recommends:

```text
single-row explicit columns
```

or:

```text
key-value settings table
```

Summarize the final recommendation and core fields.

---

## Deferred / Future Tables

Document tables that were discussed but should not be implemented yet unless future tasks request them.

Possible deferred tables:

```text
inventory_movements
payments
sale_order_status_logs
product_bundle_items
custom_orders
media_assets
```

Only include these if they are mentioned in existing research or task files.

Mark them clearly as deferred.

---

## Research References

Add a section listing source research files.

Example:

```text
- research/010_table-collections.md
- research/011-table-products-product-images.md
- research/012-table-carts.md
- research/013_table-sale-orders.md
- research/014_table-recipents.md
- research/015_table-store-settings.md
```

If a file is missing, either omit it or mention it under open questions.

---

## Open Questions

List unresolved database decisions.

Possible examples:

```text
Should carts reference product_id or product_variant_id?
Should sale_order_items reference product_id or product_variant_id?
Should store_settings use a single-row table or key-value table?
Should recipients table use one text address field or structured address fields?
Should guest checkout be supported later?
Should product bundles be researched before implementation?
```

Only include open questions supported by actual research.

---

## Writing Style

The updated `agents/012_database-model.md` should be:

* Concise
* Practical
* Implementation-oriented
* Easy for future agents to scan
* Clear about current vs proposed tables

Do not paste large sections from research files.

Summarize them.

Prefer tables and short explanations.

---

## Success Criteria

The task is complete when:

* `agents/012_database-model.md` is updated.
* Current implemented tables are documented separately from proposed tables.
* `schema_migrations` is ignored.
* Existing authentication tables are documented.
* Research outputs from completed database research tasks are summarized.
* Proposed business tables are listed clearly.
* Relationships between major tables are summarized.
* Product variant impact on carts and sale order items is documented.
* Store settings recommendation is summarized.
* Research references are included.
* Open questions are documented.
* Missing research files, if any, are noted clearly.
* No database migration is created.
* No Ecto schema is created.
* No Ecto context is created.
* No Repo queries are added.
* No production code is changed.
