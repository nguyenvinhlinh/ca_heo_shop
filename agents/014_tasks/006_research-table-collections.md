# Task 006: Research Collections Database Schema

## Objective

Research the current UI and business requirements related to collections, then propose a database schema for the `collections` table.

The output of this task is a research document.

Do not create migrations, Ecto schemas, Ecto contexts, or database changes in this task.

---

## Deliverable

Create the following file:

```text
research/010_table-collections.md
```

The document should describe the proposed database schema for `collections` based on:

* Current storefront UI
* Current admin UI
* Mock data usage
* Collection navigation requirements
* Future relationship with products

---

## Required Reading

Before starting, read:

```text
AGENTS.md
agents/001_phoenix-agent.md
agents/010_business-context.md
agents/011_architecture.md
agents/013_ui-system.md
agents/014_task-workflow.md
tasks/004-build-storefront-skeleton.md
tasks/005-admin-skeleton.md
tasks/005-01-improve-admin-skeleton-ui.md
```

Inspect current code related to:

```text
/collections
/collections/:slug
/admin/collections
/admin/collections/new
/admin/collections/:slug/edit
/admin/collections/:slug/delete
/products
/admin/products
```

If some routes or pages do not exist yet, document that clearly.

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
* Real CRUD behavior

The goal is to produce a database design proposal that can be reviewed before implementation.

---

## Known Requirements

The proposed `collections` table must support these initial requirements.

---

### Relationship to Products

One collection can contain many products.

Expected relationship:

```text
Collection has many Products
Product belongs to one Collection
```

Research and document the expected relationship.

Expected first implementation:

```text
products.collection_id
```

The research document should explain:

* Why a one-to-many relationship is enough for the first implementation
* Why many-to-many collections should be deferred unless clearly needed
* How this relationship affects product listing and collection detail pages

---

### Slug

Each collection must have a slug.

Purpose:

* Public collection URLs
* Storefront navigation
* Admin edit/delete routes

Expected route usage:

```text
/collections/:slug
/admin/collections/:slug/edit
/admin/collections/:slug/delete
```

The research document should recommend:

* Whether `slug` should be required
* Whether `slug` should be unique
* Slug format expectations
* Whether slug should be generated from Vietnamese or English name

---

### Bilingual Collection Name

Each collection must support both Vietnamese and English display names.

Required fields to research:

```text
name_vi
name_en
```

Purpose:

* `name_vi` is used for Vietnamese storefront and admin display.
* `name_en` is used for English storefront and admin display.
* The system should support bilingual collection labels in the future.

The previous generic `name` field should be reconsidered.

The research document should evaluate whether to:

```text
Option A:
Use name_vi and name_en only.

Option B:
Use name as the primary name, plus name_vi and name_en.

Option C:
Use a translation table later.
```

For the first implementation, prefer the simplest approach unless there is a strong reason not to.

Suggested default behavior:

```text
Use name_vi as the primary display name.
Use name_en as the secondary or future English display name.
```

---

### Navigation Display Order

Each collection must have a field controlling its display order in storefront navigation.

Purpose:

* Control ordering inside the header `Collections` navigation dropdown
* Support manual admin navigation ordering in the future
* Hide a collection from the header navigation when the value is `NULL`

Possible field names to evaluate:

```text
position
sort_order
nav_order
nav_display_order
```

Recommend one field name.

Preferred candidate:

```text
nav_display_order
```

Field behavior:

```text
nav_display_order integer, nullable
```

Ordering starts from `0` for collections shown in header navigation.

If `nav_display_order` is `NULL`, the header navigation UI must not display that collection name.

---

### Representative Image

Each collection must have a representative image filename.

Required field:

```text
image_filename
```

Purpose:

* Collection cards
* Homepage sections
* Storefront collection listing
* Admin collection preview

The research document should explain:

* How this field maps to local static assets now
* How this field may support uploaded files later
* Whether `image_filename` should be required or optional

---

## Areas To Research

### Storefront Usage

Inspect how collections are used or expected to be used in customer-facing pages.

Research:

* `Shop -> Collections` dropdown
* `/collections`
* `/collections/:slug`
* Homepage collection sections if any
* Product listing filtered by collection if any

Document what fields the storefront UI requires.

---

### Admin Usage

Inspect how collections are used or expected to be used in admin pages.

Research:

* Collection list page
* Create collection UI
* Edit collection UI
* Delete collection UI
* Product form collection selector if present

Document what fields admin screens require.

---

### Product Relationship

Inspect product mock data and admin product UI.

Research:

* Does product mock data currently reference collection?
* Does product UI display collection?
* Does product create/edit UI include collection?
* Does the project imply one product belongs to one collection?
* Is there any evidence that one product needs multiple collections right now?

Recommend the simplest relationship for the first real implementation.

---

## Proposed Schema Content

The research document should propose a first version of the `collections` table.

At minimum, evaluate these fields:

```text
id
name_vi
name_en
slug
image_filename
nav_display_order
inserted_at
updated_at
```

Also evaluate whether these fields are needed now or later:

```text
description
description_vi
description_en
status
is_visible
published_at
meta_title
meta_description
```

Do not add fields blindly.

For each proposed field, explain:

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
unique index on slug
index on nav_display_order
nullable nav_display_order behavior
slug format expectations
nav_display_order starts from 0 when present
```

Also document tradeoffs.

---

## Naming Recommendation

Recommend final naming for:

```text
Table name
Schema module
Context module
Route names
Relationship field on products
```

Examples to evaluate:

```text
collections
CaHeoShop.Collection
CaHeoShop.Collections.Collection
products.collection_id
```

If another naming structure is better, explain why.

---

## Expected Output Structure

The file `research/010_table-collections.md` should contain:

1. Overview
2. Current UI Findings
3. Storefront Requirements
4. Admin Requirements
5. Product Relationship Analysis
6. Proposed `collections` Table
7. Field-by-Field Explanation
8. Indexes and Constraints
9. Recommended Ecto Schema Shape
10. Recommended Migration Shape
11. Optional or Deferred Fields
12. Open Questions
13. Final Recommendation

---

## Recommended Migration Shape

The research document may include a sample migration shape as documentation only.

Do not create the actual migration file.

Example format:

```elixir
create table(:collections) do
  add :name_vi, :string, null: false
  add :name_en, :string
  add :slug, :string, null: false
  add :image_filename, :string
  add :nav_display_order, :integer

  timestamps(type: :utc_datetime)
end

create unique_index(:collections, [:slug])
create index(:collections, [:nav_display_order])
```

This sample should be treated as a proposal, not implementation.

---

## Research Guidance

During research, if additional fields appear necessary from the UI or business workflow, add them to the proposal.

However:

* Do not add fields just because ecommerce platforms usually have them.
* Clearly separate required fields from deferred fields.
* Keep the first implementation simple.
* Explain why each extra field is recommended.

---

## Success Criteria

The task is complete when:

* `research/010_table-collections.md` is created.
* The document is based on current UI and mock data observations.
* All known collection requirements are addressed.
* The proposed relationship between collections and products is clearly explained.
* Required fields are identified.
* Optional or deferred fields are separated from required fields.
* Indexes and constraints are recommended.
* Naming recommendations are included.
* Open questions are documented.
* No database migration is created.
* No Ecto schema is created.
* No Ecto context is created.
* No Repo queries are added.
* No production code is changed unless needed only to inspect references.
