# Task: Build Admin Skeleton

## Objective

Build the first administrator dashboard skeleton for Ca Heo DIY.

The goal is to create working admin routes and static LiveView pages using mock data only.

This task is focused on admin UI, navigation, operational workflow, and dashboard structure.

This task must not touch the database.

---

## Core Rule

This task is strictly UI-first and mock-data-only.

Do not create, modify, or depend on:

* Database migrations
* Ecto schemas
* Ecto contexts
* Repo queries
* Seeds
* Database-backed fixtures
* Real CRUD logic
* Real order processing
* Real inventory processing

All page data must be static mock data defined in LiveViews, helper modules, or simple in-memory functions.

The purpose is to explore administrator screens and operational workflows before designing the database model.

---

## Required Reading

Before implementation, read:

```text
AGENTS.md
agents/001_phoenix-agent.md
agents/010_business-context.md
agents/011_architecture.md
agents/013_ui-system.md
agents/014_task-workflow.md
```

Also reference:

```text
research/nexus-design-guideline.md
```

Use the Nexus Dashboard template conventions for administrator pages.

---

## Goal

Create a runnable admin skeleton with the following pages:

```text
/admin
/admin/products
/admin/orders
/admin/customers
/admin/categories
/admin/settings
```

All routes should render successfully in the browser.

All pages must use mock data only.

---

## Scope

### Admin Dashboard

Create:

```text
/admin
```

Expected sections:

* Dashboard header
* Summary cards
* Recent orders
* Product overview
* Sales or activity placeholder
* Quick action links

Use mock metrics and mock recent activity.

Possible mock metrics:

```text
Total Products
Pending Orders
Completed Orders
Revenue Placeholder
```

These metrics are exploratory and must not be treated as final reporting requirements.

---

### Product Management Page

Create:

```text
/admin/products
```

Expected sections:

* Page title
* Create product button
* Search input placeholder
* Filter controls placeholder
* Product table
* Row actions placeholder

Product table columns may include:

```text
Product
Category
Price
Status
Stock
Updated At
Actions
```

Use mock product data only.

No create, update, delete, or persistence logic is required.

---

### Order Management Page

Create:

```text
/admin/orders
```

Expected sections:

* Page title
* Search input placeholder
* Status filter placeholder
* Order table
* Row actions placeholder

Order table columns may include:

```text
Order Number
Customer
Status
Total
Created At
Actions
```

Use mock order data only.

No order status update logic is required.

---

### Customer Management Page

Create:

```text
/admin/customers
```

Expected sections:

* Page title
* Search input placeholder
* Customer table
* Row actions placeholder

Customer table columns may include:

```text
Customer
Email
Phone
Orders
Last Order
Actions
```

Use mock customer data only.

No customer CRUD logic is required.

---

### Category Management Page

Create:

```text
/admin/categories
```

Expected sections:

* Page title
* Create category button
* Category table or card list
* Row actions placeholder

Category fields may include:

```text
Name
Slug
Product Count
Status
Actions
```

Use mock category data only.

No create, update, delete, or persistence logic is required.

---

### Settings Page

Create:

```text
/admin/settings
```

Expected sections:

* Store information section
* Contact information section
* Shipping note placeholder
* Payment note placeholder
* General preferences placeholder

Forms do not need to submit.

Use static inputs, placeholders, or mock settings.

No settings should be persisted.

---

## Mock Data Rules

Mock data may be placed in:

* LiveView assigns
* Private helper functions inside LiveViews
* A simple mock data module
* Static lists or maps

Mock data must not be loaded from the database.

Mock entities may include:

```text
products
orders
customers
categories
dashboard_metrics
settings
```

These mock fields are exploratory and must not be treated as final database schema.

---

## Implementation Rules

* Use Phoenix LiveView.
* Use routes that render real pages.
* Use mock data only.
* Keep business logic minimal.
* Do not create database migrations.
* Do not create Ecto schemas.
* Do not create Ecto contexts.
* Do not call Repo.
* Do not modify existing database code.
* Do not implement real CRUD.
* Do not implement real order processing.
* Do not implement real inventory processing.
* Do not implement payment.
* Do not introduce a frontend framework.

---

## Router Rules

Place admin routes according to the current authentication strategy.

If authentication has not been fully decided yet, keep the implementation simple and document the chosen route scope in the implementation notes.

Follow Phoenix 1.8 authentication and `current_scope` rules from:

```text
agents/001_phoenix-agent.md
```

If an admin page requires authenticated access, place it inside the proper authenticated route scope and LiveView session.

Do not invent a new authentication architecture in this task.

---

## UI Rules

* Follow `agents/013_ui-system.md`.
* Use Nexus Dashboard template patterns.
* Reuse existing dashboard components when possible.
* Do not redesign the admin dashboard.
* Prefer visual consistency over originality.
* Admin pages should prioritize clarity, information density, and operational speed.
* Match neighboring pages and existing dashboard layout patterns.

---

## Success Criteria

The task is complete when:

* The admin dashboard route works.
* The admin products route works.
* The admin orders route works.
* The admin customers route works.
* The admin categories route works.
* The admin settings route works.
* All pages use mock data only.
* No database migrations are created.
* No Ecto schemas are created.
* No Ecto contexts are created.
* No Repo queries are added.
* No real CRUD logic is implemented.
* Pages visually follow the Nexus Dashboard template.
* The app compiles successfully.
* `mix format` has been run.
* `mix precommit` passes if available.

---

## Expected Outcome

After this task, the project should have a visible administrator workflow:

```text
Dashboard
  → Products
  → Orders
  → Customers
  → Categories
  → Settings
```

This skeleton will be used to discover future admin workflows and domain concepts such as Product, Category, Order, Customer, Inventory, Store Settings, and Admin Operations.

Do not finalize database design during this task.
