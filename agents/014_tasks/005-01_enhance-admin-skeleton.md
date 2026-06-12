# Task 005-01: Improve Admin Skeleton UI

## Objective

Improve the admin skeleton UI after completing `005-admin-skeleton.md`.

This task focuses on improving dashboard metrics, replacing quick actions with a useful chart placeholder, and adding mock UI screens for managing products and collections.

This task must remain UI-first and mock-data-only.

Do not implement real database persistence or real CRUD behavior.

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
tasks/005-admin-skeleton.md
```

Also reference:

```text
research/nexus-design-guideline.md
```

Use the Nexus Dashboard template conventions for admin pages.

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
* Real product persistence
* Real collection persistence
* Real delete behavior
* Real inventory logic
* Real profit calculation

All data must come from mock data.

The goal is to explore admin workflows before designing the database model.

---

## Main Change 1: Improve Admin Dashboard Metrics

Update the admin dashboard page:

```text
/admin
```

### Current Dashboard Metric Changes

The dashboard currently has a `Revenue Placeholder`.

Add the following metric cards near it:

```text
Revenue Placeholder
Profit Placeholder
Inventory Value Placeholder
```

### Profit Placeholder

Add a metric card for:

```text
Profit Placeholder
```

Purpose:

* Represent estimated profit.
* This is only a mock dashboard metric.
* Do not implement real profit calculation.

### Inventory Value Placeholder

Add a metric card for:

```text
Inventory Value Placeholder
```

Purpose:

* Represent the estimated value of products currently in stock.
* Even though the business uses 3D printing, some products may be printed in advance and stored as inventory.
* Future products may have original cost fields, such as material cost or production cost.
* This is only a mock dashboard metric.
* Do not implement real inventory calculation.

Example dashboard metric cards:

```text
Revenue Placeholder
Profit Placeholder
Inventory Value Placeholder
Pending Orders
Total Products
```

Use mock values only.

---

## Main Change 2: Replace Quick Actions

On the admin dashboard:

```text
/admin
```

Remove the existing `Quick Actions` section.

Replace it with a chart or chart-like placeholder showing products with the highest purchase count.

### Expected Replacement

Add a section such as:

```text
Top Purchased Products
```

This section should show mock data for products that have been purchased the most.

Possible UI options:

* Bar chart placeholder
* Horizontal progress bars
* Ranked list with purchase counts
* Card-based chart-like section

Use the Nexus Dashboard visual style.

### Mock Data Example

```text
Laptop Stand              128 purchases
Cable Hanger               96 purchases
Toothbrush Holder          72 purchases
Hydroponic Net Cup Holder  48 purchases
Razor Holder               31 purchases
```

Do not implement a real charting library unless already available in the project.

Prefer simple HTML/Tailwind/DaisyUI chart-like UI.

---

## Main Change 3: Add Collection Management UI

Add admin UI screens for managing collections.

Collections are used by the storefront `Shop -> Collections` navigation.

This task only creates mock UI.

Do not implement real collection persistence.

---

### Collection List Page

Create or update:

```text
/admin/collections
```

Expected sections:

* Page title
* Create collection button
* Search input placeholder
* Collection table or card list
* Row actions

Collection fields may include:

```text
Name
Slug
Description
Product Count
Status
Updated At
Actions
```

Actions should include:

```text
View
Edit
Delete
```

All data must be mock data.

---

### Create Collection UI

Add UI for creating a new collection.

Preferred route:

```text
/admin/collections/new
```

Expected form fields:

```text
Name
Slug
Description
Status
Image Placeholder
```

Expected buttons:

```text
Cancel
Create Collection
```

The form does not need to submit to a backend.

It may show placeholder behavior only.

---

### Edit Collection UI

Add UI for editing a collection.

Preferred route:

```text
/admin/collections/:slug/edit
```

Expected form fields:

```text
Name
Slug
Description
Status
Image Placeholder
```

Expected buttons:

```text
Cancel
Save Changes
```

Use mock collection data based on the slug.

The form does not need to persist changes.

---

### Delete Collection UI

Add UI for deleting a collection.

Acceptable approaches:

* Delete confirmation modal
* Delete confirmation page
* Inline confirmation placeholder

Expected behavior:

* The collection list should show a delete action.
* Clicking delete may open a confirmation modal or navigate to a placeholder confirmation page.
* No real delete operation should happen.

If using a route, preferred route:

```text
/admin/collections/:slug/delete
```

Expected confirmation content:

```text
Are you sure you want to delete this collection?
This is a mock action and will not delete real data.
```

---

## Main Change 4: Add Product Management UI

Add admin UI screens for managing products.

This task only creates mock UI.

Do not implement real product persistence.

---

### Product List Page

Update:

```text
/admin/products
```

Expected sections:

* Page title
* Create product button
* Search input placeholder
* Filter controls placeholder
* Product table
* Row actions

Product fields may include:

```text
Product
Collection
Price
Cost
Status
Stock
Updated At
Actions
```

Actions should include:

```text
View
Edit
Delete
```

All data must be mock data.

---

### Create Product UI

Add UI for creating a new product.

Preferred route:

```text
/admin/products/new
```

Expected form fields:

```text
Name
Slug
Description
Collection
Price
Cost
Stock
Status
Image Placeholder
```

Expected buttons:

```text
Cancel
Create Product
```

The form does not need to submit to a backend.

It may show placeholder behavior only.

---

### Edit Product UI

Add UI for editing a product.

Preferred route:

```text
/admin/products/:slug/edit
```

Expected form fields:

```text
Name
Slug
Description
Collection
Price
Cost
Stock
Status
Image Placeholder
```

Expected buttons:

```text
Cancel
Save Changes
```

Use mock product data based on the slug.

The form does not need to persist changes.

---

### Delete Product UI

Add UI for deleting a product.

Acceptable approaches:

* Delete confirmation modal
* Delete confirmation page
* Inline confirmation placeholder

Expected behavior:

* The product list should show a delete action.
* Clicking delete may open a confirmation modal or navigate to a placeholder confirmation page.
* No real delete operation should happen.

If using a route, preferred route:

```text
/admin/products/:slug/delete
```

Expected confirmation content:

```text
Are you sure you want to delete this product?
This is a mock action and will not delete real data.
```

---

## Mock Data Requirements

Use mock data for:

```text
dashboard_metrics
top_purchased_products
products
collections
```

Mock product fields may include:

```text
name
slug
description
collection
price
cost
stock
status
image
updated_at
purchase_count
```

Mock collection fields may include:

```text
name
slug
description
product_count
status
image
updated_at
```

These fields are exploratory and must not be treated as final database schema.

Mock data may be placed in:

* LiveView assigns
* Private helper functions inside LiveViews
* A simple mock data module
* Static lists or maps

Do not load mock data from the database.

---

## Suggested Admin Routes

Add routes only as needed for mock UI pages.

Suggested routes:

```text
/admin
/admin/products
/admin/products/new
/admin/products/:slug/edit
/admin/products/:slug/delete
/admin/collections
/admin/collections/new
/admin/collections/:slug/edit
/admin/collections/:slug/delete
```

If existing route naming differs, follow the current project conventions.

Do not create database-backed resources.

---

## Implementation Rules

* Use Phoenix LiveView.
* Use mock data only.
* Reuse existing admin layout and components.
* Follow Nexus Dashboard patterns.
* Keep business logic minimal.
* Do not create database migrations.
* Do not create Ecto schemas.
* Do not create Ecto contexts.
* Do not call Repo.
* Do not implement real create, edit, or delete behavior.
* Do not implement real inventory logic.
* Do not implement real profit calculation.
* Do not introduce a frontend framework.
* Do not redesign the entire admin dashboard.

---

## UI Rules

* Follow `agents/013_ui-system.md`.
* Use Nexus Dashboard template patterns.
* Prefer consistency over originality.
* Admin pages should prioritize clarity, information density, and operational speed.
* Match neighboring admin pages and existing dashboard layout patterns.
* Reuse table, card, form, badge, and modal patterns where possible.

---

## Pages To Check

After implementation, verify these pages:

```text
/admin
/admin/products
/admin/products/new
/admin/products/:slug/edit
/admin/collections
/admin/collections/new
/admin/collections/:slug/edit
```

If delete confirmation routes are added, also verify:

```text
/admin/products/:slug/delete
/admin/collections/:slug/delete
```

---

## Success Criteria

The task is complete when:

* `/admin` shows `Revenue Placeholder`.
* `/admin` shows `Profit Placeholder`.
* `/admin` shows `Inventory Value Placeholder`.
* `/admin` no longer shows the old `Quick Actions` section.
* `/admin` shows a top purchased products chart or chart-like placeholder.
* `/admin/collections` exists or is updated.
* Collection list UI exists.
* Create collection UI exists.
* Edit collection UI exists.
* Delete collection UI exists as a mock confirmation flow.
* `/admin/products` is updated.
* Create product UI exists.
* Edit product UI exists.
* Delete product UI exists as a mock confirmation flow.
* Product UI includes a mock `Cost` field where appropriate.
* Product UI includes mock inventory/stock display where appropriate.
* All data is mock data only.
* No database migrations are created.
* No Ecto schemas are created.
* No Ecto contexts are created.
* No Repo queries are added.
* No real CRUD logic is implemented.
* The app compiles successfully.
* `mix format` has been run.
* `mix precommit` passes if available.

---

## Expected Outcome

After this task, the admin skeleton should better represent the future operational workflow:

```text
Dashboard
  → Revenue
  → Profit
  → Inventory Value
  → Top Purchased Products

Collections
  → List
  → Create
  → Edit
  → Delete

Products
  → List
  → Create
  → Edit
  → Delete
```

This improves the admin skeleton while keeping the project UI-first, mock-data-only, and database-free.
