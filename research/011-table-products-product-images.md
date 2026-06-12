# Products, Product Variants, and Product Images Research

## 1. Overview

This document proposes first database shapes for:

```text
products
product_variants
product_images
```

The current application uses mock product data in the storefront and admin LiveViews. Products already appear on the homepage, `/products`, `/products/:slug`, `/collections/:slug`, `/cart`, `/checkout`, `/admin/products`, product create/edit pages, and product delete confirmation pages.

This task is research only. The examples below are proposals, not implemented migrations, Ecto schemas, contexts, Repo queries, seeds, tests, cart behavior, checkout behavior, order behavior, or variant image switching behavior.

## 2. Current UI Findings

Current storefront routes:

- `/products`
- `/products/:slug`
- `/cart`
- `/checkout`
- `/collections`
- `/collections/:slug`

Current admin routes:

- `/admin/products`
- `/admin/products/new`
- `/admin/products/:slug/edit`
- `/admin/products/:slug/delete`
- `/admin/collections`

Route placement:

- Storefront routes are inside the existing `:current_user` LiveView session and `:browser` pipeline because they work with or without authentication.
- Admin routes are inside the existing `:require_authenticated_user` LiveView session and authenticated browser scope because they are administrator workflows.

No real catalog, cart, checkout, or order persistence exists yet.

Existing related research:

- `research/010_table-collections.md` exists and recommends `products.collection_id`.
- `research/012-table-cart-items.md` exists and recommends cart items reference `product_variants.id`.
- `research/013_table-sale-orders.md` does not exist yet.

Storefront mock product fields currently include:

- `name`
- `slug`
- `description`
- `price`
- `price_cents`
- `image`
- `alt_image`
- `category`
- `collection_slug`
- `availability`
- `sale`
- `variants`
- `specifications`

Admin mock product fields currently include:

- `name`
- `sku`
- `slug`
- `description`
- `collection`
- `price`
- `cost`
- `status`
- `stock`
- `updated_at`
- `image`
- `purchase_count`

The current mock UI has product variants as a list of strings, product images as one main image plus one alternate image, and price/cost/stock displayed at product level. Task 007 asks the first real database design to move sellable option data into `product_variants`.

## 3. Storefront Product Requirements

The `/products` page needs:

- product name
- product slug
- primary image
- display price
- sale marker or future visible status
- collection/category filter support
- search and sort support later

The `/products/:slug` page needs:

- product name
- slug lookup
- description content
- collection/category label
- product gallery images
- variant selection labels
- selected or default variant price
- selected or default variant availability
- selected variant image when available
- fallback product image when a variant image is missing
- related products by collection or category

The homepage featured product section and collection detail pages need:

- product name
- slug
- primary image
- display price
- collection relationship for filtering

The cart page and checkout summary are mock-only today. They currently hold product references, product image, product name, price, and quantity. If variants are the sellable options, future cart items should reference `product_variant_id`, while optionally denormalizing product and variant display details for order snapshots later.

## 4. Admin Product Requirements

The `/admin/products` table currently shows:

- product image
- product name
- SKU
- collection name
- selling price
- production cost
- status
- stock
- updated date
- view/edit/delete actions by slug

The `/admin/products/new` and `/admin/products/:slug/edit` static form currently includes:

- name
- slug
- description
- collection selector
- status selector
- price
- cost
- stock
- image preview placeholder

The `/admin/products/:slug/delete` page identifies products by:

- name
- slug

The admin UI implies future management of variants, costs, prices, stock, and images, even though the current form is still product-level. The first real database should model price, cost, and stock at the variant level so the admin can later expand the form without a migration that moves core sellable data.

## 5. Collection Relationship Analysis

Recommended first relationship:

```text
Product belongs to Collection
```

Recommended database field:

```text
products.collection_id
```

The collection research recommends that collections do not need to load belonging products from the collection schema. Product-side queries can filter by `products.collection_id` when rendering collection pages or product tables.

One collection per product is enough for the first implementation because:

- storefront collection pages currently filter products by one `collection_slug`
- admin product forms expose one collection selector
- admin product tables show one collection column
- no current UI assigns one product to multiple collections

Many-to-many product collections should be deferred until there is a clear workflow for multiple collection assignment, membership ordering, or cross-collection merchandising.

Recommended delete behavior:

- `products.collection_id` should reference `collections.id` with `on_delete: :restrict`.
- Admin should not delete a collection while products still belong to it.
- The owner should reassign or remove products first.

## 6. Product Variant Requirements

Recommended table:

```text
product_variants
```

Recommended first relationship:

```text
Product has many ProductVariants
ProductVariant belongs to Product
```

A product variant is the sellable option. For the first version, keep the variant value simple and human-readable:

```text
variant_name = "PLA Red"
variant_name = "PETG Black"
variant_name = "ABS White"
```

Do not split variant attributes into material, color, size, option, or option-value tables yet. The current UI only needs one selected variant label per product.

Required variant fields:

- `product_id`
- `variant_name`
- `production_cost`
- `selling_price`
- `stock_quantity`
- `image_filename`
- `display_order`

## 7. Product Variant Pricing Recommendation

`selling_price` should live on `product_variants`.

Reasoning:

- variants are sellable options
- material/color combinations may have different prices
- cart and checkout should price the selected variant, not a generic product
- product cards can show the lowest visible variant price

Recommended storage:

- integer VND
- no decimal type for VND
- required
- must be greater than or equal to `0`

`products.selling_price` should not be part of the first normalized schema. If storefront listing performance later requires a cached display price, add a derived product-level field later and make its maintenance explicit.

## 8. Product Variant Stock Recommendation

`stock_quantity` should live on `product_variants`.

Reasoning:

- different materials/colors can have different available quantities
- storefront availability depends on the selected variant
- future cart quantity validation should check selected variant stock
- future inventory value calculations need variant-level stock and cost

Recommended storage:

- integer
- required
- default `0`
- must be greater than or equal to `0`

Do not allow negative stock in the first implementation. Do not create inventory movement tables yet because the current UI only needs a simple stock number.

`products.stock_quantity` should not be part of the first normalized schema. A cached total can be added later if admin dashboards need it.

## 9. Product Variant Image Recommendation

Use both product-level images and variant-level representative images:

```text
product_images: general product gallery
product_variants.image_filename: selected variant preview image
```

Recommended behavior:

- product detail loads product gallery from `product_images`
- selecting a variant may show `product_variants.image_filename`
- if the selected variant has no `image_filename`, fall back to the primary product image
- `product_images` remains useful for general product photos, detail shots, lifestyle images, and thumbnails

Do not create `product_variant_images` yet. The current UI does not require multiple images per variant.

`product_variants.image_filename` should be optional so a variant can exist before a variant-specific image is prepared.

## 10. Proposed `products` Table

Recommended first fields:

```text
id
collection_id
slug
name_vi
name_en
description_vi
description_en
inserted_at
updated_at
```

Recommended fields not included on `products` in the first version:

```text
production_cost
selling_price
stock_quantity
```

Those fields belong to `product_variants` because variants are the sellable options.

## 11. Proposed `product_variants` Table

Recommended first fields:

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

`display_order` is product-local ordering for variant radios/selectors. It should be required with default `0`.

## 12. Proposed `product_images` Table

Recommended first fields:

```text
id
product_id
filename
display_order
inserted_at
updated_at
```

Product images should remain product-level only in the first implementation. Variant-specific representative images belong on `product_variants.image_filename`.

## 13. Field-by-Field Explanation

### `products.id`

- Type: primary key
- Required: yes
- Default: generated by database
- Needed now: yes
- Purpose: stable product identity and target for variants, images, cart items, and order item snapshots

### `products.collection_id`

- Type: foreign key to `collections.id`
- Required: yes
- Default: none
- Needed now: yes
- Purpose: product grouping, collection pages, admin product table, product form selector

### `products.slug`

- Type: string
- Required: yes
- Default: none
- Needed now: yes
- Purpose: `/products/:slug`, `/admin/products/:slug/edit`, and `/admin/products/:slug/delete`

Use a unique lowercase URL-safe slug:

```text
modular-desk-organizer
starter-electronics-kit
custom-plant-holder
```

Generate from `name_en` when available. If `name_en` is blank, generate from `name_vi` using Vietnamese accent removal and URL-safe normalization.

### `products.name_vi`

- Type: string
- Required: yes
- Default: none
- Needed now: yes
- Purpose: primary Vietnamese display name

### `products.name_en`

- Type: string
- Required: no
- Default: none
- Needed now: yes
- Purpose: English display name for future bilingual UI

Use `name_vi` and `name_en` only. Do not also keep a generic `name`, because it creates ambiguity about the source of truth.

### `products.description_vi`

- Type: text column in migration, `:string` field in Ecto schema
- Required: no
- Default: none
- Needed now: yes
- Purpose: Vietnamese product detail description and admin-managed product content

### `products.description_en`

- Type: text column in migration, `:string` field in Ecto schema
- Required: no
- Default: none
- Needed now: yes
- Purpose: English product detail description for future bilingual UI

Use `description_vi` and `description_en` only. Do not also keep a generic `description`, because it creates ambiguity about the source of truth.

### `product_variants.id`

- Type: primary key
- Required: yes
- Default: generated by database
- Needed now: yes
- Purpose: stable sellable option identity for cart items and order items

### `product_variants.product_id`

- Type: foreign key to `products.id`
- Required: yes
- Default: none
- Needed now: yes
- Purpose: associate each variant with one product

### `product_variants.variant_name`

- Type: string
- Required: yes
- Default: none
- Needed now: yes
- Purpose: combined human-readable material/color value such as `PLA Red`

### `product_variants.production_cost`

- Type: integer VND
- Required: yes
- Default: `0`
- Needed now: yes
- Purpose: profit estimate, inventory value, dashboard metrics, and material/production cost tracking

Use integer VND and avoid decimals.

### `product_variants.selling_price`

- Type: integer VND
- Required: yes
- Default: none
- Needed now: yes
- Purpose: actual sellable price for the selected variant

Use integer VND and avoid decimals.

### `product_variants.stock_quantity`

- Type: integer
- Required: yes
- Default: `0`
- Needed now: yes
- Purpose: selected variant availability and future cart quantity validation

Do not allow negative stock.

### `product_variants.image_filename`

- Type: string
- Required: no
- Default: none
- Needed now: yes
- Purpose: variant-specific representative image

If missing, product detail should fall back to the primary product image.

### `product_variants.display_order`

- Type: integer
- Required: yes
- Default: `0`
- Needed now: yes
- Purpose: stable variant ordering within a product

Do not allow negative values.

### `product_images.id`

- Type: primary key
- Required: yes
- Default: generated by database
- Needed now: yes
- Purpose: stable image identity

### `product_images.product_id`

- Type: foreign key to `products.id`
- Required: yes
- Default: none
- Needed now: yes
- Purpose: associate gallery images with one product

### `product_images.filename`

- Type: string
- Required: yes
- Default: none
- Needed now: yes
- Purpose: product gallery image filename or asset key

Store a filename or relative asset key, not a hard-coded public URL. The presentation layer can resolve it to `/images/...` now and uploaded file storage later.

### `product_images.display_order`

- Type: integer
- Required: yes
- Default: `0`
- Needed now: yes
- Purpose: product gallery ordering

The first image by `display_order` should be treated as the primary image unless a separate primary marker is added later.

## 14. Cart and Order Impact

Cart and sale order research files do not exist yet. Based on task 007's variant model, future cart items and sale order items should reference:

```text
product_variant_id
```

not only:

```text
product_id
```

Reasoning:

- variant is the sellable option
- variant determines selling price
- variant determines production cost
- variant determines stock quantity
- variant may determine the preview image

Future cart items can join through `product_variant.product_id` when product name, slug, collection, or gallery data is needed.

Future sale order items should snapshot product and variant display data at the time of purchase, for example:

- product name
- product slug
- variant name
- selling price
- production cost if used for profit reporting
- image filename if useful for order history

Do not implement cart, checkout, or order behavior in this task.

## 15. Indexes and Constraints

Recommended product constraints:

- `products.collection_id` not null
- `products.slug` not null
- `products.name_vi` not null
- unique index on `products.slug`
- index on `products.collection_id`
- foreign key from `products.collection_id` to `collections.id`
- slug format validation: `^[a-z0-9]+(?:-[a-z0-9]+)*$`

Recommended variant constraints:

- `product_variants.product_id` not null
- `product_variants.variant_name` not null
- `product_variants.production_cost` not null, default `0`
- `product_variants.selling_price` not null
- `product_variants.stock_quantity` not null, default `0`
- `product_variants.display_order` not null, default `0`
- `production_cost >= 0`
- `selling_price >= 0`
- `stock_quantity >= 0`
- `display_order >= 0`
- index on `product_variants.product_id`
- index on `product_variants.product_id, display_order`
- unique index on `product_variants.product_id, variant_name`
- foreign key from `product_variants.product_id` to `products.id`

Recommended image constraints:

- `product_images.product_id` not null
- `product_images.filename` not null
- `product_images.display_order` not null, default `0`
- `display_order >= 0`
- index on `product_images.product_id`
- index on `product_images.product_id, display_order`
- foreign key from `product_images.product_id` to `products.id`

Delete behavior:

- `products.collection_id`: `on_delete: :restrict`
- `product_variants.product_id`: `on_delete: :delete_all`
- `product_images.product_id`: `on_delete: :delete_all`

Deleting a product can delete its variants and gallery images because they have no meaning without the product. Deleting a collection should be restricted while products still reference it.

## 16. Recommended Ecto Schema Shape

Documentation-only example:

```elixir
schema "products" do
  belongs_to :collection, CaHeoShop.Collections.Collection

  field :slug, :string
  field :name_vi, :string
  field :name_en, :string
  field :description_vi, :string
  field :description_en, :string

  has_many :variants, CaHeoShop.ProductVariants.ProductVariant
  has_many :images, CaHeoShop.ProductImages.ProductImage

  timestamps(type: :utc_datetime)
end
```

```elixir
schema "product_variants" do
  belongs_to :product, CaHeoShop.Products.Product

  field :variant_name, :string
  field :production_cost, :integer, default: 0
  field :selling_price, :integer
  field :stock_quantity, :integer, default: 0
  field :image_filename, :string
  field :display_order, :integer, default: 0

  timestamps(type: :utc_datetime)
end
```

```elixir
schema "product_images" do
  belongs_to :product, CaHeoShop.Products.Product

  field :filename, :string
  field :display_order, :integer, default: 0

  timestamps(type: :utc_datetime)
end
```

## 17. Recommended Migration Shape

Documentation-only example:

```elixir
create table(:products) do
  add :collection_id, references(:collections, on_delete: :restrict), null: false
  add :slug, :string, null: false
  add :name_vi, :string, null: false
  add :name_en, :string
  add :description_vi, :text
  add :description_en, :text

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

Optional check constraints:

```elixir
create constraint(:product_variants, :production_cost_non_negative,
         check: "production_cost >= 0")

create constraint(:product_variants, :selling_price_non_negative,
         check: "selling_price >= 0")

create constraint(:product_variants, :stock_quantity_non_negative,
         check: "stock_quantity >= 0")

create constraint(:product_variants, :variant_display_order_non_negative,
         check: "display_order >= 0")

create constraint(:product_images, :image_display_order_non_negative,
         check: "display_order >= 0")
```

## 18. Optional or Deferred Fields

### `products.status`

Defer. The admin mock table has status, but there is no real publishing workflow yet. Add only when product visibility or draft workflows are implemented.

### `products.is_visible`

Defer. If storefront visibility is needed before a broader status workflow, `is_visible` may be simpler than `status`.

### `products.short_description`

Defer. The current UI can use `description_vi` excerpts or product card-specific copy later. Add only if product cards need managed short copy.

### `products.description`

Do not use a generic `description` with `description_vi` and `description_en` in the first implementation. It would create ambiguity about the source of truth.

### Translation table

Defer. The first implementation only needs Vietnamese and English product descriptions.

### `products.published_at`

Defer. There is no scheduled publishing workflow.

### `products.meta_title` and `products.meta_description`

Defer. SEO-specific fields can be added after basic catalog persistence exists.

### `product_variants.sku`

Defer. The admin mock table shows product SKU, but the known variant requirements do not require variant SKU yet. Add later if fulfillment, labels, or inventory import/export workflows need it.

### `product_variants.is_default`

Defer. The default variant can initially be the first visible variant by `display_order`. Add `is_default` later if admin needs explicit default selection.

### `product_variants.is_visible`

Defer. Add later if a variant needs to be hidden while the parent product remains visible.

### `product_images.alt_text`

Defer. Helpful for accessibility, but not necessary for the first persistence step. If added later, consider bilingual alt text.

### `product_images.caption`

Defer. Current UI does not display captions.

### `product_images.is_primary`

Defer. Use the first image by `display_order` as primary in the first implementation.

### `product_images.metadata`

Defer. Do not add a metadata blob until there is a concrete uploaded-file workflow that needs it.

## 19. Open Questions

- Should `description_vi` be required before publishing a product, or can a product be saved with no description?
- Should every product require at least one product image at the application level?
- Should every product require at least one variant at the application level?
- Should a product with zero available variant stock still appear on the storefront?
- Should future product cards show "from lowest variant price" or require an explicit default variant?
- Should admin preserve product-level SKU for internal grouping, or move SKU entirely to variants later?
- Should hidden product or hidden variant behavior use `status` or `is_visible` first?

## 20. Final Recommendation

Create three simple product-related tables:

```text
products
product_variants
product_images
```

Recommended naming:

```text
Product context module: CaHeoShop.Products
Product schema: CaHeoShop.Products.Product
Product variant context module: CaHeoShop.ProductVariants
Product variant schema: CaHeoShop.ProductVariants.ProductVariant
Product image context module: CaHeoShop.ProductImages
Product image schema: CaHeoShop.ProductImages.ProductImage
Product routes: /products/:slug and /admin/products/:slug/edit
Relationship fields:
  products.collection_id
  product_variants.product_id
  product_images.product_id
```

Recommended design:

- products describe the product and route identity
- product variants represent sellable options with price, cost, stock, and optional variant image
- product images provide the general product gallery
- cart items and sale order items should reference `product_variant_id`
- product cards should show the lowest visible variant price or the default variant price
- variant image selection should fall back to the primary product image when the variant image is missing

Do not split variants into material/color/size option tables yet. Do not add product variant image galleries yet. Keep the first product schema set small and aligned with the current Ca Heo DIY UI.
