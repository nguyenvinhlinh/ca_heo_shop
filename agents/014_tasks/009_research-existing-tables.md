# Task 007: Research Current Database Model

## Objective

Research the current database tables and update the project database model documentation.

The expected output is an updated database model document:

```text
agents/012_database-model.md
```

This task documents the current database state only.

Do not create new migrations, schemas, contexts, or database changes.

---

## Current Known Database Tables

The current database contains:

```text
users
user_tokens
schema_migrations
```

Ignore:

```text
schema_migrations
```

Only document application tables.

If the actual table name is different, such as `user` instead of `users`, document the real table name found in the project.

---

## Required Reading

Before starting, read:

```text
AGENTS.md
agents/001_phoenix-agent.md
agents/010_business-context.md
agents/011_architecture.md
agents/014_task-workflow.md
research/004-commerce-order-flow.md
```

Also inspect:

```text
priv/repo/migrations
lib/**/accounts
lib/**/*user*
```

The goal is to understand what the existing authentication system created.

Use `research/004-commerce-order-flow.md` only as background for why commerce tables are not implemented yet. This task must document the current database state, not proposed commerce tables.

---

## Core Rule

This is a research and documentation task only.

Do not create, modify, or run:

* New database migrations
* New Ecto schemas
* New Ecto contexts
* New Repo queries for application behavior
* New tests
* New CRUD behavior

Do not change production code unless necessary to inspect references.

---

## Research Scope

Research and document the existing application tables.

### Users Table

Document the current users table.

Include:

* Table name
* Related Ecto schema module
* Context module
* Fields
* Field types
* Required fields
* Unique constraints
* Indexes
* Timestamps
* Purpose of the table

Also document how this table relates to Phoenix authentication.

---

### User Tokens Table

Document the current user tokens table.

Include:

* Table name
* Related Ecto schema module if any
* Fields
* Field types
* Required fields
* Indexes
* Constraints
* Purpose of the table

Explain that this table is used by authentication flows such as session, email confirmation, password reset, or similar token-based workflows if applicable.

---

## File To Update

Update:

```text
agents/012_database-model.md
```

If the file does not exist, create it.

The document should represent the current known database model.

Do not include future tables such as:

```text
collections
products
product_images
orders
order_items
cart
inventory
```

unless they already exist in the database.

Future proposed tables should remain in separate research files.

---

## Expected Document Structure

The updated `agents/012_database-model.md` should contain:

1. Overview
2. Current Database Status
3. Existing Application Tables
4. Ignored System Tables
5. `users` Table
6. `user_tokens` Table
7. Current Authentication Model
8. Notes for Future Tables
9. Open Questions

---

## Documentation Guidance

The document should be clear that the database model is still in an early stage.

Use wording similar to:

```text
The current database only contains authentication-related tables.
Business tables such as collections, products, orders, and inventory have not been implemented yet.
```

Also mention that future database proposals are documented separately in research files.

Examples:

```text
research/010_table-collections.md
research/011-table-products-product-images.md
```

Only reference these files if they exist.

---

## Success Criteria

The task is complete when:

* `agents/012_database-model.md` exists.
* The file documents the current database status.
* The users table is documented.
* The user tokens table is documented.
* `schema_migrations` is explicitly ignored.
* No future business tables are presented as existing tables.
* No database migration is created.
* No Ecto schema is created.
* No Ecto context is created.
* No production behavior is changed.
* The document clearly separates current database reality from future database proposals.
