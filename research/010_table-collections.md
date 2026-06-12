# Collections Table Research

## 1. Overview

This document proposes the first database shape for the `collections` table.

The current application uses mock collection data in both the storefront and admin LiveViews. Collections already appear in storefront navigation, `/collections`, `/collections/:slug`, homepage collection cards, admin collection management pages, and the admin product form.

This task is research only. The examples below are proposals, not implemented migrations, Ecto schemas, contexts, Repo queries, seeds, tests, or CRUD behavior.

## 2. Current UI Findings

Current storefront routes:

- `/collections`
- `/collections/:slug`
- `/products`
- `/products/:slug`

Current admin routes:

- `/admin/collections`
- `/admin/collections/new`
- `/admin/collections/:slug/edit`
- `/admin/collections/:slug/delete`
- `/admin/products`
- `/admin/products/new`
- `/admin/products/:slug/edit`
- `/admin/products/:slug/delete`

Route placement:

- Storefront routes are inside the existing `:current_user` LiveView session and `:browser` pipeline because they work with or without authentication.
- Admin routes are inside the existing `:require_authenticated_user` LiveView session and authenticated browser scope because they are administrator workflows.

Storefront collection mock data currently uses:

- `name`
- `slug`
- `image`
- `description`

Storefront product mock data currently uses:

- `category`
- `collection_slug`

Admin collection mock data currently uses:

- `name`
- `slug`
- `description`
- `product_count`
- `status`
- `image`
- `updated_at`

Admin product mock data currently uses:

- `collection`

The current UI depends on stable collection slugs, display names, representative images, descriptions, and a single collection relationship per product. The current mock data does not include a navigation ordering field yet, but the task requirement now calls for `nav_display_order`.

## 3. Storefront Requirements

The storefront header and mobile drawer show a `Collections` navigation dropdown. Each collection shown there needs:

- display name
- slug
- non-null `nav_display_order`

`nav_display_order` controls header navigation display only. Header navigation should order collections by ascending `nav_display_order`, starting at `0`. If `nav_display_order` is `NULL`, the header navigation UI must not display that collection name.

The `/collections` page renders all collection cards. Each card needs:

- display name
- slug
- representative image

The `/collections/:slug` page finds one collection by slug, shows a hero image, collection name, and description, then filters products by the matching mock `collection_slug`. It needs:

- slug
- display name
- representative image
- description
- relationship from products to collection

The homepage includes `Shop by Collections`, using the same collection card data:

- display name
- slug
- representative image

The `/products` page currently has a static category filter. Product mock data includes `collection_slug`, so the future database should support product listing filters by collection.

## 4. Admin Requirements

The `/admin/collections` table currently shows:

- image
- name
- slug
- description
- product count
- status
- updated date
- view, edit, and delete actions based on slug

The `/admin/collections/new` and `/admin/collections/:slug/edit` static form currently includes:

- name
- slug
- description
- status
- product count
- image preview placeholder

The `/admin/collections/:slug/delete` page identifies the collection by:

- name
- slug

The `/admin/products` table shows one collection label per product.

The `/admin/products/new` and `/admin/products/:slug/edit` form includes one collection selector. The mock form stores the collection display name, but the database implementation should store `products.collection_id` and display the collection name from the product side.

`product_count` should not be stored on `collections` in the first implementation. It can be derived with a count query when real products exist.

Admin should eventually expose `nav_display_order` as an optional integer field. Leaving it blank should mean the collection is hidden from header navigation.

## 5. Product Relationship Analysis

Recommended first relationship:

```text
Collection has many Products
Product belongs to one Collection
```

Recommended database field on products:

```text
products.collection_id
```

This relationship fits the current UI because every mock product belongs to one collection:

- storefront collection pages filter products by one `collection_slug`
- admin product tables show one collection column
- admin product forms expose one collection selector

A many-to-many relationship should be deferred. There is no current UI for assigning one product to multiple collections, managing collection memberships, ordering products differently per collection, or resolving duplicate product appearances across collections.

For the first implementation, collection detail pages should query products where `products.collection_id` matches the selected collection. Product listing pages can also filter by `collection_id` when real filters are added.

## 6. Proposed `collections` Table

Recommended table name:

```text
collections
```

Recommended first fields:

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

Minimum viable version if descriptions are deferred:

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

`description_vi` and `description_en` are recommended now because the current collection detail hero and admin collection table already display collection descriptions.

## 7. Field-by-Field Explanation

### `id`

- Type: primary key
- Required: yes
- Default: generated by database
- Needed now: yes
- Purpose: stable internal identity and target for `products.collection_id`

### `name_vi`

- Type: string
- Required: yes
- Default: none
- Needed now: yes
- Purpose: primary Vietnamese display name for storefront and admin

Use `name_vi` as the primary display name. This matches the expected Vietnamese customer base while still allowing English labels.

### `name_en`

- Type: string
- Required: no for the first implementation
- Default: none
- Needed now: yes
- Purpose: English display name for future bilingual storefront and admin UI

Make `name_en` optional initially so the owner can create Vietnamese-first collections before English copy is ready.

### `slug`

- Type: string
- Required: yes
- Default: none
- Needed now: yes
- Purpose: public and admin route identity

Current route usage:

```text
/collections/:slug
/admin/collections/:slug/edit
/admin/collections/:slug/delete
```

`slug` should be unique and use lowercase URL-safe text with hyphens:

```text
3d-printed-products
diy-kits
custom-orders
```

Slug generation should use `name_en` when available because ASCII English names usually create clearer public URLs. If `name_en` is blank, generate from `name_vi` using Vietnamese accent removal and URL-safe normalization.

### `description_vi`

- Type: text column in the migration, `:string` field in the Ecto schema
- Required: no
- Default: none
- Needed now: recommended
- Purpose: Vietnamese collection summary for collection detail hero, admin table, and simple metadata later

### `description_en`

- Type: text column in the migration, `:string` field in the Ecto schema
- Required: no
- Default: none
- Needed now: recommended
- Purpose: English collection summary for future bilingual UI

### `image_filename`

- Type: string
- Required: no for the first implementation
- Default: none
- Needed now: yes
- Purpose: representative image for collection cards, homepage collection section, collection detail hero, and admin preview

The current UI uses static paths such as:

```text
/images/storefront/category-prints.svg
/images/storefront/category-kits.svg
/images/storefront/category-garden.svg
```

The first implementation should store a filename or relative asset key, then resolve it into a static path in the presentation layer. Keeping this as `image_filename` avoids coupling database rows to the current URL shape. Later, uploaded files can reuse the same field if the value becomes an object key or stored filename.

This should be optional initially so a collection can be drafted before an image exists. The UI should use a fallback image when absent.

### `nav_display_order`

- Type: integer
- Required: no
- Default: none
- Needed now: yes
- Purpose: ordering and visibility for the storefront header navigation

Recommended name:

```text
nav_display_order
```

This is more explicit than `position`, `sort_order`, or `nav_order` because the value controls navigation display order, not generic collection ordering.

Collections shown in header navigation should use integer values starting at `0`. When `nav_display_order` is `NULL`, the header navigation UI must not display that collection name.

`NULL` should only control header navigation visibility. The collection can still exist, appear in admin screens, appear on `/collections` if the storefront wants a full directory, and be available through direct routes if the application allows it.

### `inserted_at`

- Type: UTC datetime timestamp
- Required: yes
- Default: generated by Ecto timestamps
- Needed now: yes
- Purpose: record creation tracking

### `updated_at`

- Type: UTC datetime timestamp
- Required: yes
- Default: generated by Ecto timestamps
- Needed now: yes
- Purpose: admin updated-date display

## 8. Indexes and Constraints

Recommended constraints:

- `name_vi` not null
- `slug` not null
- `nav_display_order` nullable
- optional check constraint: `nav_display_order IS NULL OR nav_display_order >= 0`

Recommended indexes:

- unique index on `slug`
- index on `nav_display_order`

Recommended slug validation:

```text
^[a-z0-9]+(?:-[a-z0-9]+)*$
```

The unique `slug` index is required because public and admin routes use slug lookup. Duplicate slugs would make collection detail, edit, and delete routes ambiguous.

The `nav_display_order` index supports ordered header navigation. A partial index on non-null values would match the header query most closely if the database adapter supports it:

```elixir
create index(:collections, [:nav_display_order], where: "nav_display_order IS NOT NULL")
```

A regular index is also acceptable and simpler:

```elixir
create index(:collections, [:nav_display_order])
```

For a small catalog, either index is mostly a clarity and future-proofing choice rather than a performance requirement.

## 9. Recommended Ecto Schema Shape

Documentation-only example:

```elixir
schema "collections" do
  field :name_vi, :string
  field :name_en, :string
  field :slug, :string
  field :description_vi, :string
  field :description_en, :string
  field :image_filename, :string
  field :nav_display_order, :integer

  timestamps(type: :utc_datetime)
end
```

Suggested changeset rules:

- require `name_vi`
- require `slug`
- validate slug format
- enforce unique slug constraint
- validate `nav_display_order` is greater than or equal to `0` only when present

Do not validate `nav_display_order` as required. `NULL` has business meaning: hide from header navigation.

## 10. Recommended Migration Shape

Documentation-only example:

```elixir
create table(:collections) do
  add :name_vi, :string, null: false
  add :name_en, :string
  add :slug, :string, null: false
  add :description_vi, :text
  add :description_en, :text
  add :image_filename, :string
  add :nav_display_order, :integer

  timestamps(type: :utc_datetime)
end

create unique_index(:collections, [:slug])
create index(:collections, [:nav_display_order])

create constraint(:collections, :nav_display_order_non_negative,
         check: "nav_display_order IS NULL OR nav_display_order >= 0")
```

Future product migration shape, documented only:

```elixir
alter table(:products) do
  add :collection_id, references(:collections, on_delete: :restrict), null: false
end

create index(:products, [:collection_id])
```

Use `on_delete: :restrict` first. Admin should not accidentally delete a collection that still owns products.

## 11. Optional or Deferred Fields

### `description`

Do not use a generic `description` if bilingual descriptions are introduced now. Prefer `description_vi` and `description_en`.

### `name`

Do not keep a generic `name` alongside `name_vi` and `name_en` in the first implementation. It would create ambiguity about the source of truth.

Recommended first approach:

```text
Use name_vi and name_en only.
Use name_vi as the primary display name.
Use name_en for English display and slug generation when present.
```

### Translation Table

Defer a translation table. The project only needs Vietnamese and English labels now. A translation table would add complexity without a current need for arbitrary locales.

### `status`

Defer unless the next implementation explicitly needs draft or paused collections.

The admin mock table displays `status`, but there is no real publish workflow yet. `nav_display_order = NULL` now covers the specific requirement of hiding a collection from header navigation.

### `is_visible`

Defer unless storefront visibility must differ from record existence and navigation visibility. Do not use `is_visible` for the header navigation rule because `nav_display_order = NULL` already defines that behavior.

### `published_at`

Defer. There is no scheduled publishing workflow.

### `meta_title`

Defer. SEO fields are useful later but are not necessary for the first working catalog.

### `meta_description`

Defer. `description_vi` and `description_en` can support simple metadata until dedicated SEO controls exist.

### `product_count`

Do not store. Calculate from associated products.

### `image_alt`

Defer. If editable accessibility copy becomes necessary later, add bilingual fields such as `image_alt_vi` and `image_alt_en`.

## 12. Open Questions

- Should `/collections` show every collection, or only collections with non-null `nav_display_order`?
- Should direct `/collections/:slug` access work for collections hidden from header navigation?
- Should the admin form label `nav_display_order` as "Header navigation order" to make the `NULL` behavior clear?
- Should `image_filename` store only a basename, such as `category-prints.svg`, or a relative key, such as `storefront/category-prints.svg`?
- Should `products.collection_id` be required for every product, or should draft products be allowed without a collection?
- Should the storefront default language be Vietnamese only at launch, with English fields stored but not displayed?

## 13. Final Recommendation

Create a simple `collections` table with bilingual names, bilingual descriptions, a unique slug, an optional representative image filename, and nullable header navigation order.

Recommended naming:

```text
Table name: collections
Schema module: CaHeoShop.Catalog.Collection
Context module: CaHeoShop.Catalog
Public route identity: /collections/:slug
Admin route identity: /admin/collections/:slug/edit and /admin/collections/:slug/delete
Relationship field on products: products.collection_id
```

Recommended required fields:

```text
name_vi
slug
inserted_at
updated_at
```

Recommended optional-but-supported fields:

```text
name_en
description_vi
description_en
image_filename
nav_display_order
```

Use a one-to-many relationship between collections and products. Defer many-to-many collection membership, generic status workflows, publishing schedules, and SEO-specific fields until the UI or business workflow requires them.
