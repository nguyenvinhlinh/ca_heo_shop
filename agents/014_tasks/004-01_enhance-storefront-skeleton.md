# Task 004-01: Fix and Improve Storefront UI

## Objective

Fix and improve the storefront UI after reviewing the result of `004-build-storefront-skeleton.md`.

This task focuses on:

* Improving the customer-facing storefront header navigation
* Moving account navigation out of the main navbar
* Fixing the homepage image display bug

This task must remain UI-first and mock-data-only.

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
tasks/004-build-storefront-skeleton.md
```

Also reference:

```text
research/online-store-design-guideline.md
```

Use the Online Store template conventions for customer-facing pages.

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

All data must come from mock data.

---

## Main Change 1: Storefront Header Navigation

Update the storefront header navigation.

The main navbar should contain:

```text
Products
Collections
Cart
```

Remove `Account` from the main navbar.

Account-related navigation should be moved into the logged-in user dropdown.

---

## Navigation Requirements

### Products

The `Products` navigation item should remain as a normal link.

Expected behavior:

```text
Products → /products
```

Purpose:

* List all products.
* Keep the current product listing behavior.
* Do not change the meaning of the Products page.

---

### Collections

The `Collections` navigation item should become a dropdown menu.

Expected behavior:

```text
Collections
  → Collection list dropdown
```

When the user opens the `Collections` dropdown, it should display a list of all available collections.

Each collection item should link to a collection page or placeholder route.

Example dropdown items:

```text
3D Printed Products
DIY Kits
Home Accessories
Hydroponics
Custom Orders
```

Use mock collection data.

---

### Cart

The `Cart` navigation item should remain as a normal link.

Expected behavior:

```text
Cart → /cart
```

Purpose:

* Let customers access the cart quickly.
* Keep the current cart behavior.
* Do not implement real cart persistence.

---

## Account Navigation

Remove `Account` from the main navbar.

Account navigation should not appear as a top-level navbar item.

Instead, account navigation should belong inside the logged-in user display area.

The intended behavior is:

```text
User display area
  → email or full name
      → Orders
      → Settings
      → Logout
```

---

## Logged-In User Dropdown

If the storefront header already has a user display area, update it.

If it does not exist yet, create a simple mock logged-in user dropdown.

The dropdown trigger should display either:

```text
Full Name
```

or:

```text
Email
```

Example mock user:

```text
Halo Nguyen
halo@example.com
```

Dropdown items:

```text
Orders
Settings
Logout
```

Expected behavior:

```text
Orders   → /orders
Settings → /account/settings
Logout   → placeholder action or existing logout route if already available
```

For this task:

* Use mock logged-in user data.
* Do not implement real authentication.
* Do not implement real logout logic.
* Do not modify authentication architecture.
* Do not create real user settings persistence.
* Do not create real order history logic.

If existing auth routes already exist, reuse them carefully without redesigning authentication.

If routes do not exist, add placeholder routes using mock data.

---

## Account-Related Routes

If these routes already exist, reuse them.

If they do not exist, add simple placeholder routes using mock data:

```text
/orders
/account/settings
```

Expected behavior:

* `/orders` displays a mock list of customer orders.
* `/account/settings` displays a mock settings page with placeholder sections for password, full name, and address.
* `/account` may remain available if it already exists, but it should not be linked from the main navbar.

No database should be used.

---

## Collection Routing

If collection routes already exist, reuse them.

If collection routes do not exist, add simple placeholder routes using mock data.

Preferred route pattern:

```text
/collections
/collections/:slug
```

Expected behavior:

* `/collections` displays all mock collections.
* `/collections/:slug` displays products or placeholder content for one mock collection.

No database should be used.

---

## Main Change 2: Fix Homepage Image Display Bug

The current homepage/index page has a UI bug where images are not displayed correctly.

Investigate and fix the image display issue on the homepage.

Expected behavior:

* Homepage images should render correctly.
* Product images should display correctly if shown on the homepage.
* Collection images should display correctly if shown on the homepage.
* Broken image icons should not appear.
* Image containers should preserve layout even when using mock images.

Possible areas to check:

* Image paths
* Static asset paths
* `~p` path usage
* Template image references
* Mock data image URLs
* CSS classes affecting image visibility
* Image container dimensions
* Responsive image behavior

Use mock images or existing static assets.

Do not introduce remote image dependencies unless already used by the template.

---

## Header UI Requirements

The header should:

* Follow the Online Store template style.
* Remain visually consistent with existing storefront pages.
* Work on desktop and mobile.
* Keep navigation simple.
* Avoid introducing a new design language.

The `Collections` dropdown should:

* Be easy to discover.
* Be readable.
* Match existing dropdown or menu styling from the Online Store template if available.
* Behave naturally on both desktop and mobile.

The user dropdown should:

* Be visually separated from the main navigation.
* Display the mock user's full name or email.
* Contain account-related actions.
* Match existing account/user menu patterns from the Online Store template if available.

---

## Mock Data Requirements

Use mock data for:

```text
collections
logged_in_user
orders
account_settings
homepage_images
products
```

Mock collection fields may include:

```text
name
slug
description
image
product_count
```

Mock user fields may include:

```text
full_name
email
```

Mock order fields may include:

```text
order_number
status
total
created_at
items_count
```

Mock product or homepage image fields may include:

```text
name
slug
image
alt
```

These fields are exploratory and must not be treated as final database schema.

Mock data may be placed in:

* LiveView assigns
* Private helper functions inside LiveViews
* A simple mock data module
* Static lists or maps

Do not load mock data from the database.

---

## Pages To Check

After implementation, verify these pages:

```text
/
/products
/products/:slug
/cart
/checkout
/account
/orders
/account/settings
/collections
/collections/:slug
```

The header should behave consistently across all storefront pages.

The homepage should display images correctly.

---

## Implementation Rules

* Use Phoenix LiveView.
* Use existing storefront components when possible.
* Reuse the current storefront layout/header if it exists.
* Do not rewrite the entire storefront.
* Do not redesign the whole header from scratch unless necessary.
* Do not introduce JavaScript unless the existing template pattern requires it.
* Do not introduce a frontend framework.
* Do not create database migrations.
* Do not create Ecto schemas.
* Do not create Ecto contexts.
* Do not call Repo.
* Do not implement real authentication.
* Do not implement real logout.
* Do not implement real customer settings.
* Do not implement real order history.
* Do not use database-backed image records.

---

## UI Rules

* Follow `agents/013_ui-system.md`.
* Follow Online Store template patterns.
* Prefer consistency over originality.
* Keep the storefront mobile-friendly.
* Match neighboring pages and existing storefront components.
* Use existing dropdown/navigation patterns from the template if available.
* Fix image rendering without redesigning the homepage.

---

## Success Criteria

The task is complete when:

* `Products` links to `/products`.
* `Collections` is shown in the storefront header.
* `Collections` opens a dropdown list of mock collections.
* Collection dropdown items are clickable.
* The homepage collection section heading uses `Shop by Collections`.
* `Cart` links to `/cart`.
* `Account` is removed from the main navbar.
* A mock logged-in user display area exists if appropriate.
* The user dropdown displays `Orders`, `Settings`, and `Logout`.
* `Orders` links to `/orders`.
* `Settings` links to `/account/settings`.
* `Logout` is a placeholder or uses an existing logout route if available.
* `/account` may still exist, but it is not shown as a main navbar item.
* `/orders` works if added.
* `/account/settings` works if added.
* `/collections` works if added.
* `/collections/:slug` works if added.
* Header works across storefront pages.
* Header remains responsive.
* Homepage images display correctly.
* No broken image icons appear on the homepage.
* All data is mock data only.
* No database migrations are created.
* No Ecto schemas are created.
* No Ecto contexts are created.
* No Repo queries are added.
* No real authentication logic is added.
* The app compiles successfully.
* `mix format` has been run.
* `mix precommit` passes if available.

---

## Expected Outcome

After this task, the storefront navigation should become:

```text
Products
  → All products

Collections
  → All Collections
  → 3D Printed Products
  → DIY Kits
  → Home Accessories
  → Hydroponics
  → Custom Orders

Cart
  → Cart page

User
  → Orders
  → Settings
  → Logout
```

The homepage should also render its images correctly.

This improves storefront discoverability and visual quality while keeping the project UI-first and mock-data-only.
