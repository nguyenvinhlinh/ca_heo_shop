# Task 007: Research Products, Product Variants, and Product Images Database Schema

## Objective

Research the current storefront and admin UI related to products, then propose database schemas for:

```text
products
product_variants
product_images
```

The output of this task is a research document, not implementation code.

Do not create migrations, Ecto schemas, Ecto contexts, or database changes in this task.

---

## Deliverable

Create the following file:

```text
research/011-table-products-product-images.md
```

The document should describe the proposed database schema for `products`, `product_variants`, and `product_images` based on:

* Current UI requirements
* Mock data usage
* Storefront product pages
* Admin product management screens
* Product variant requirements
* Product image requirements
* Cart and order implications
* Ecommerce needs for Ca Heo DIY

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
tasks/004-build-storefront-skeleton.md
tasks/005-admin-skeleton.md
tasks/005-01-improve-admin-skeleton-ui.md
tasks/006-research-table-collections.md
```

Also read the collections research output if it exists:

```text
research/010_table-collections.md
```

Also read these research files if they exist:

```text
research/012-table-carts.md
research/013_table-sale-orders.md
```

Inspect current code related to:

```text
/products
/products/:slug
/cart
/checkout
/collections
/collections/:slug
/admin/products
/admin/products/new
/admin/products/:slug/edit
/admin/products/:slug/delete
/admin/collections
```

If some routes, pages, or research files do not exist yet, document that clearly.

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
* Real cart behavior
* Real checkout behavior
* Real order behavior
* Real variant selection behavior

The goal is to produce a database design proposal that can be reviewed before implementation.

---

## Known Product Requirements

The proposed product-related database model must support these initial requirements.

---

### Collection Relationship

Each product belongs to exactly one collection.

Expected relationship:

```text
Product belongs to Collection
Collection has many Products
```

Expected field:

```text
collection_id
```

The research document should explain:

* Why a product belongs to one collection in the first implementation
* Why many-to-many product collections should be deferred unless clearly needed
* Recommended foreign key constraints
* Expected behavior when a collection is deleted
* How collection detail pages should list products

---

### Product Slug

Each product must have a slug.

Purpose:

* Public product detail URLs
* Admin edit/delete routes

Expected route usage:

```text
/products/:slug
/admin/products/:slug/edit
/admin/products/:slug/delete
```

The research document should recommend:

* Whether `slug` should be unique
* Whether `slug` should be required
* Slug format expectations
* Whether slug should be generated from Vietnamese or English name

---

### Bilingual Product Name

Each product must support both Vietnamese and English display names.

Required fields to research:

```text
name_vi
name_en
```

Purpose:

* `name_vi` is used for Vietnamese storefront and admin display.
* `name_en` is used for English storefront and admin display.
* The system should support bilingual product labels in the future.

The document should evaluate whether to use:

```text
Option A:
name_vi and name_en only

Option B:
name as primary name, plus name_vi and name_en

Option C:
a translation table later
```

For the first implementation, prefer the simplest approach unless there is a strong reason not to.

Suggested default behavior:

```text
Use name_vi as the primary display name.
Use name_en as the secondary or future English display name.
```

---

### Product Description

Each product must have a product description.

The admin should be able to enter Markdown content to introduce and explain the product.

Required field to research:

```text
description_markdown
```

Purpose:

* Product detail page
* Long-form product introduction
* Admin-managed product content

The research document should evaluate whether product description should be:

```text
Option A:
description_markdown

Option B:
description_markdown_vi and description_markdown_en

Option C:
short_description plus description_markdown

Option D:
translation table later
```

For the first implementation, recommend the simplest approach that still supports the current storefront.

The document should also mention that Markdown rendering requires safe HTML handling in future implementation.

Do not implement Markdown rendering in this task.

---

## Known Product Variant Requirements

A product can have multiple variants.

Proposed table name:

```text
product_variants
```

Each product variant belongs to one product.

Expected relationship:

```text
Product has many ProductVariants
ProductVariant belongs to Product
```

A variant represents one sellable option of a product.

Example:

```text
Product: Universal Phone Stand

Variants:
- PLA Red    - 50,000 VND
- PLA Black  - 50,000 VND
- PETG White - 65,000 VND
```

---

### Simple Variant Modeling Rule

For the first implementation, keep variant modeling simple.

Each product only has one simple variant type.

The current expected variant type is a combined material and color value.

Do not split variant attributes into separate material and color fields.

Do not create separate tables for:

```text
materials
colors
variant_options
variant_option_values
```

Do not model variants like this:

```text
Material: PLA / PETG / ABS
Color: Red / Black / White
Size: Small / Medium / Large
```

Instead, model each variant as one combined human-readable value:

```text
PLA Red
PETG Black
ABS White
```

This keeps the first version simple and easier to implement.

---

### Product Variant Fields

Research and propose the `product_variants` table.

Minimum fields to evaluate:

```text
id
product_id
variant_name
production_cost
selling_price
stock_quantity
image_filename
display_order
inserted_at
updated_at
```

The field `variant_name` represents the combined material and color value.

Example:

```text
variant_name = "PLA Red"
selling_price = 50000
image_filename = "universal-phone-stand-pla-red.jpg"
```

Also evaluate whether these fields are needed now or later:

```text
sku
is_default
is_visible
```

Do not add fields blindly.

For each proposed field, explain:

* Purpose
* Type
* Required or optional
* Default value if any
* Whether it is needed now or can be deferred

---

### Variant Pricing

Each variant can have its own selling price.

Required field to research:

```text
selling_price
```

Example:

```text
PLA Red     - 50,000 VND
PETG White  - 65,000 VND
```

The research document should recommend:

* Whether `selling_price` belongs on `product_variants`
* Whether `products.selling_price` should be removed, deferred, or kept only as a cached display price
* Whether storefront product cards should show the lowest variant price
* Whether cart and sale order items should reference product variants instead of products
* Whether the value should be stored as integer VND
* Required constraints
* Validation expectations

Recommended direction to evaluate:

```text
Products describe the product.
Product variants represent sellable options with price.
```

---

### Variant Production Cost

Each variant can have its own production cost.

Required field to research:

```text
production_cost
```

Purpose:

* Estimate profit per variant
* Support future admin dashboard profit metrics
* Support inventory value estimation
* Track material and production cost for 3D printed products

The research document should recommend:

* Whether `production_cost` belongs on `product_variants`
* Whether `products.production_cost` should be removed, deferred, or kept only as an optional default
* Field type
* Whether the value should be stored as integer VND
* Whether decimal should be avoided for VND pricing
* Whether the field is required or optional
* Default value if any

Important:

Because variants may represent different material and color combinations, production cost may vary by variant.

Example:

```text
PLA Red may have a different cost than PETG Black.
```

---

### Variant Stock Quantity

Each variant can have its own stock quantity.

Required field to research:

```text
stock_quantity
```

Purpose:

* Admin product inventory display
* Storefront availability indicator
* Future inventory value calculation
* Correct stock tracking for material and color combinations

The research document should recommend:

* Whether `stock_quantity` belongs on `product_variants`
* Whether `products.stock_quantity` should be removed, deferred, or kept only as a cached total
* Field type
* Default value
* Whether negative stock should be allowed
* Whether cart quantity should later validate against selected variant stock

Example:

```text
PLA Red: 10 items
PLA Black: 5 items
PETG White: 2 items
```

Do not design complex inventory movement tables unless the current UI clearly requires them.

---

### Variant Image Filename

Each product variant should have its own representative image.

Required field to research:

```text
image_filename
```

Purpose:

* Show the correct product image when a user selects a variant
* Support variants that differ visually by material and color
* Improve product detail UX
* Allow storefront UI to switch image immediately based on selected variant

Example:

```text
Product: Universal Phone Stand

Variants:
- PLA Red
  - selling_price: 50,000 VND
  - image_filename: universal-phone-stand-pla-red.jpg

- PLA Black
  - selling_price: 50,000 VND
  - image_filename: universal-phone-stand-pla-black.jpg

- PETG White
  - selling_price: 65,000 VND
  - image_filename: universal-phone-stand-petg-white.jpg
```

The research document should explain:

* Whether `image_filename` is required or optional
* Whether variant images should override the default product image
* Whether the product detail page should fall back to product images if variant image is missing
* Whether `product_images` remains useful as a general gallery even when variants have their own image

Recommended first behavior to evaluate:

```text
Use product_images for the general product gallery.
Use product_variants.image_filename for the selected variant preview image.
If variant image_filename is missing, fall back to the primary product image.
```

Do not implement JavaScript, LiveView events, image switching behavior, or real variant selection behavior in this task.

---

## Known Product Images Requirements

A product can have many general product images.

Proposed table name:

```text
product_images
```

Each product image belongs to one product.

Expected relationship:

```text
Product has many ProductImages
ProductImage belongs to Product
```

Initial required fields:

```text
product_id
display_order
filename
```

Product images are used for the general product gallery.

Variant-specific representative images should be researched as:

```text
product_variants.image_filename
```

Do not create `product_variant_images` unless the current UI clearly requires multiple images per variant.

---

### Product Image Fields

Research and propose the `product_images` table.

Minimum fields to evaluate:

```text
id
product_id
filename
display_order
inserted_at
updated_at
```

Also evaluate whether these fields are needed now or later:

```text
alt_text
caption
is_primary
metadata
```

Do not add fields blindly.

For each proposed field, explain:

* Purpose
* Type
* Required or optional
* Default value if any
* Whether it is needed now or can be deferred

Important:

Research whether product images should remain product-level only.

For the first implementation, prefer:

```text
product_images belong to products
product_variants have one image_filename
```

---

## Areas To Research

### Storefront Usage

Inspect how products are used or expected to be used in customer-facing pages.

Research:

* Product listing page
* Product detail page
* Homepage featured products
* Collection detail pages
* Cart page
* Checkout summary
* Variant selection UI if present or implied
* Image behavior when selecting a variant

Document what fields the UI needs.

---

### Admin Usage

Inspect how products are used or expected to be used in admin pages.

Research:

* Product list page
* Create product UI
* Edit product UI
* Delete product UI
* Product table
* Product form
* Product image UI if present
* Product variant UI if present or implied
* Cost and stock display if present

Document what fields admin screens need.

---

### Relationship With Collections

Review `research/010_table-collections.md` if available.

Document how products should connect to collections.

Research:

* Whether current collection UI expects product counts
* Whether current product UI expects collection name
* Whether product form includes collection selector
* Whether collection detail pages list products

Recommend the simplest first implementation.

---

### Relationship With Carts And Orders

If cart or sale order research exists, inspect:

```text
research/012-table-carts.md
research/013_table-sale-orders.md
```

Research whether carts and sale order items should reference:

```text
product_id
```

or:

```text
product_variant_id
```

Important:

If variants are sellable options, cart items and sale order items may need to reference `product_variant_id`.

The research document should clearly document this impact.

Do not modify cart or sale order research files in this task unless explicitly requested.

---

## Proposed Schema Content

The research document should propose first versions of these tables:

```text
products
product_variants
product_images
```

At minimum, evaluate these fields for `products`:

```text
id
collection_id
slug
name_vi
name_en
description_markdown
inserted_at
updated_at
```

Also evaluate whether these fields should remain on `products` or move to `product_variants`:

```text
production_cost
selling_price
stock_quantity
```

At minimum, evaluate these fields for `product_variants`:

```text
id
product_id
variant_name
production_cost
selling_price
stock_quantity
image_filename
display_order
inserted_at
updated_at
```

At minimum, evaluate these fields for `product_images`:

```text
id
product_id
filename
display_order
inserted_at
updated_at
```

Also evaluate whether these fields are needed now or later:

```text
status
is_visible
sku
short_description
description_markdown_vi
description_markdown_en
published_at
meta_title
meta_description
is_default
alt_text
caption
metadata
```

Separate required fields from optional or deferred fields.

---

## Indexes and Constraints

The research document should recommend database constraints and indexes.

Evaluate:

```text
unique index on products.slug
index on products.collection_id
foreign key from products.collection_id to collections.id

index on product_variants.product_id
index on product_variants.product_id + display_order
unique index on product_variants.product_id + variant_name
foreign key from product_variants.product_id to products.id

index on product_images.product_id
index on product_images.display_order
index on product_images.product_id + display_order
foreign key from product_images.product_id to products.id

not null constraints
price and cost constraints
stock quantity constraints
slug format expectations
```

Also document tradeoffs.

---

## Naming Recommendation

Recommend final naming for:

```text
Table names
Schema modules
Context module
Route names
Relationship fields
```

Examples to evaluate:

```text
products
product_variants
product_images

CaHeoShop.Catalog.Product
CaHeoShop.Catalog.ProductVariant
CaHeoShop.Catalog.ProductImage
CaHeoShop.Catalog

products.collection_id
product_variants.product_id
product_images.product_id
```

If another naming structure is better, explain why.

---

## Expected Output Structure

The file `research/011-table-products-product-images.md` should contain:

1. Overview
2. Current UI Findings
3. Storefront Product Requirements
4. Admin Product Requirements
5. Collection Relationship Analysis
6. Product Variant Requirements
7. Product Variant Pricing Recommendation
8. Product Variant Stock Recommendation
9. Product Variant Image Recommendation
10. Proposed `products` Table
11. Proposed `product_variants` Table
12. Proposed `product_images` Table
13. Field-by-Field Explanation
14. Cart and Order Impact
15. Indexes and Constraints
16. Recommended Ecto Schema Shape
17. Recommended Migration Shape
18. Optional or Deferred Fields
19. Open Questions
20. Final Recommendation

---

## Recommended Migration Shape

The research document may include sample migration shapes as documentation only.

Do not create the actual migration files.

Example format:

```elixir
create table(:products) do
  add :collection_id, references(:collections, on_delete: :restrict), null: false
  add :slug, :string, null: false
  add :name_vi, :string, null: false
  add :name_en, :string
  add :description_markdown, :text

  timestamps(type: :utc_datetime)
end

create unique_index(:products, [:slug])
create index(:products, [:collection_id])
```

```elixir
create table(:product_variants) do
  add :product_id, references(:products, on_delete: :delete_all), null: false
  add :variant_name, :string, null: false
  add :production_cost, :integer, null: false, default: 0
  add :selling_price, :integer, null: false
  add :stock_quantity, :integer, null: false, default: 0
  add :image_filename, :string
  add :display_order, :integer, null: false, default: 0

  timestamps(type: :utc_datetime)
end

create index(:product_variants, [:product_id])
create index(:product_variants, [:product_id, :display_order])
create unique_index(:product_variants, [:product_id, :variant_name])
```

```elixir
create table(:product_images) do
  add :product_id, references(:products, on_delete: :delete_all), null: false
  add :filename, :string, null: false
  add :display_order, :integer, null: false, default: 0

  timestamps(type: :utc_datetime)
end

create index(:product_images, [:product_id])
create index(:product_images, [:product_id, :display_order])
```

These samples should be treated as proposals, not implementation.

The final research document may recommend a different shape if research supports it.

---

## Research Guidance

During research, if additional fields appear necessary from the UI or business workflow, add them to the proposal.

However:

* Do not add fields just because ecommerce platforms usually have them.
* Clearly separate required fields from deferred fields.
* Keep the first implementation simple.
* Explain why each extra field is recommended.
* Do not split product variants into complex option tables.
* Do not create material/color tables.
* Do not create variant option tables.
* Do not create product variant image galleries unless clearly needed.
* Do not implement cart, checkout, or order behavior in this task.

---

## Success Criteria

The task is complete when:

* `research/011-table-products-product-images.md` is created.
* The document is based on current UI and mock data observations.
* All known product requirements are addressed.
* Simple product variant requirements are addressed.
* The proposed relationship between products and collections is clearly explained.
* The proposed `products` table is documented.
* The proposed `product_variants` table is documented.
* The proposed `product_images` table is documented.
* The document evaluates whether price, production cost, and stock belong on products or product variants.
* The document evaluates `product_variants.image_filename`.
* The document explains how variant image selection affects product detail UI.
* The document explains fallback behavior when a variant image is missing.
* The document keeps `product_images` as product-level gallery unless research clearly proves variant galleries are needed.
* The document evaluates whether carts and sale order items should reference products or product variants.
* Required fields are identified.
* Optional or deferred fields are separated from required fields.
* Indexes and constraints are recommended.
* No database migration is created.
* No Ecto schema is created.
* No Ecto context is created.
* No Repo queries are added.
* No variant image switching behavior is implemented.
* No production code is changed unless needed only to inspect references.
