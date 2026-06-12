# Collections Table Research

## 1. Overview

This document proposes the first database shape for `collections`.

Current storefront/admin collection behavior is mock-only. Collections appear in storefront navigation, `/collections`, `/collections/:slug`, homepage collection cards, admin collection listing, collection forms, and product forms.

This is research only. Do not create migrations, schemas, contexts, Repo queries, seeds, tests, or CRUD behavior from this document.

## 2. Current UI Findings

Storefront routes:

```text
/collections
/collections/:slug
/products
/products/:slug
```

Admin routes:

```text
/admin/collections
/admin/collections/new
/admin/collections/:slug/edit
/admin/collections/:slug/delete
/admin/products
```

Storefront mock collection fields:

```text
name
slug
image
description
```

Admin mock collection fields:

```text
name
slug
description
product_count
status
image
updated_at
```

The storefront routes are in the existing `:current_user` LiveView session and `:browser` pipeline because they work with or without authentication. Admin routes are in the existing `:require_authenticated_user` LiveView session because they are owner/admin workflows.

## 3. Commerce Flow Boundary

`research/004-commerce-order-flow.md` uses collections only as catalog context. Collections should not own order, fulfillment, payment, return, financial, inventory, or procedure status behavior.

## 4. Relationship to Products

Recommended first relationship:

```text
Product belongs to Collection
products.collection_id -> collections.id
```

One collection per product is enough for the first implementation because the current UI shows one collection label per product, collection pages filter by one `collection_slug`, and product forms expose one collection selector.

Defer many-to-many product collections until there is UI for multi-collection assignment, per-collection product ordering, or merchandising.

The collection schema does not need a `has_many :products` association for the first proposal. Product-side queries can filter by `products.collection_id`.

## 5. Proposed `collections` Table

Recommended fields:

```text
id
name_vi
name_en
slug
description_vi
description_en
image_filename
nav_display_order
inserted_at
updated_at
```

## 6. Field Notes

- `name_vi`: required Vietnamese display name and primary display fallback.
- `name_en`: optional English display name and useful slug source.
- `slug`: required unique public/admin route identifier.
- `description_vi`: optional text for collection pages/admin.
- `description_en`: optional English description.
- `image_filename`: optional representative image filename.
- `nav_display_order`: nullable integer. Values start at `0`; `NULL` hides the collection from header navigation.

Do not store `product_count`; derive it from products when needed.

Do not store collection workflow `status` in the first schema unless a real admin publishing workflow is requested. Header visibility is already handled by nullable `nav_display_order`.

## 7. Constraints and Indexes

Recommended:

```elixir
create unique_index(:collections, [:slug])
create index(:collections, [:nav_display_order])
create constraint(:collections, :nav_display_order_non_negative,
         check: "nav_display_order IS NULL OR nav_display_order >= 0")
```

## 8. Naming

Recommended:

```text
Table: collections
Schema: CaHeoShop.Catalog.Collection
Context: CaHeoShop.Catalog
```

## 9. Open Questions

- Should admin later expose a separate published/hidden flag beyond `nav_display_order`?
- Should slug generation prefer `name_en`, or normalize `name_vi` when English is missing?
- Should collection images be stored as filenames first or a future media table?

## 10. Final Recommendation

Create a simple `collections` proposal with bilingual names/descriptions, unique slug, optional image, and nullable `nav_display_order`. Keep collections focused on catalog grouping and navigation.
