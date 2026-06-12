# Task 004: Build Storefront Skeleton

## Objective

Build the first customer-facing storefront skeleton for Ca Heo DIY.

The goal is to create working routes and static LiveView pages using mock data only.

This task is focused on UI, navigation, and customer journey exploration.

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
* Real cart persistence
* Real checkout persistence
* Real order creation

All page data must be static mock data defined in LiveViews, helper modules, or simple in-memory functions.

The purpose is to explore screens and user flows before designing the database model.

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
research/online-store-design-guideline.md
```

Use the Online Store template conventions for customer-facing pages.

---

## Goal

Create a runnable storefront skeleton with the following pages:

```text
/
/products
/products/:slug
/cart
/checkout
/account
```

All routes should render successfully in the browser.

All pages must use mock data only.

---

## Scope

### Homepage

Create a customer-facing homepage.

Expected sections:

* Header
* Hero section
* Featured products
* Product categories
* Promotional or brand section
* Footer

Use mock products and mock categories.

The homepage should visually follow the Online Store template.

---

### Product Listing Page

Create:

```text
/products
```

Expected sections:

* Page title
* Product grid
* Search input placeholder
* Filter area placeholder
* Sort dropdown placeholder
* Pagination placeholder

Search, filters, sorting, and pagination do not need to work yet.

Use mock product data only.

---

### Product Detail Page

Create:

```text
/products/:slug
```

Expected sections:

* Product image gallery placeholder
* Product name
* Product price
* Product description
* Product specifications
* Availability indicator
* Add to cart button
* Related products section

Use mock product data based on the slug.

The Add to Cart button does not need to persist data.

---

### Cart Page

Create:

```text
/cart
```

Expected sections:

* Cart item list
* Quantity controls
* Subtotal
* Shipping note placeholder
* Checkout button

Use mock cart items only.

Quantity controls do not need to persist changes.

---

### Checkout Page

Create:

```text
/checkout
```

Expected sections:

* Customer information form
* Shipping address form
* Order summary
* Payment method placeholder
* Place order button

The checkout form does not need to submit to a backend.

No order should be created.

No database should be used.

---

### Account Page

Create:

```text
/account
```

Expected sections:

* Account overview
* Profile summary
* Address placeholder
* Recent orders placeholder

Use mock customer data only.

Authentication integration is not required in this task unless the existing router structure requires it.

---

## Mock Data Rules

Mock data may be placed in:

* LiveView assigns
* Private helper functions inside LiveViews
* A simple mock data module
* Static lists or maps

Mock data must not be loaded from the database.

Mock products should include enough fields to support the UI:

```text
name
slug
description
price
image
category
availability
```

These fields are exploratory and must not be treated as final database schema.

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
* Do not implement real cart persistence.
* Do not implement real checkout.
* Do not implement payment.
* Do not introduce a frontend framework.

---

## UI Rules

* Follow `agents/013_ui-system.md`.
* Use Online Store template patterns.
* Reuse existing components when possible.
* Do not redesign the storefront.
* Prefer visual consistency over originality.
* Keep pages mobile-friendly.

---

## Success Criteria

The task is complete when:

* The homepage route works.
* The product listing route works.
* The product detail route works.
* The cart route works.
* The checkout route works.
* The account route works.
* All pages use mock data only.
* No database migrations are created.
* No Ecto schemas are created.
* No Ecto contexts are created.
* No Repo queries are added.
* Pages visually follow the Online Store template.
* The app compiles successfully.
* `mix format` has been run.
* `mix precommit` passes if available.

---

## Expected Outcome

After this task, the project should have a visible customer journey:

```text
Homepage
  → Product Listing
  → Product Detail
  → Cart
  → Checkout
```

This skeleton will be used to discover future domain concepts such as Product, Cart, Order, Customer, Address, and Checkout.

Do not finalize database design during this task.
