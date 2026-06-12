# Products, Product Variants, and Product Images Research

## 1. Overview

This document proposes first database shapes for:

```text
products
product_variants
product_images
```

Current product behavior is mock-only in storefront and admin UI. This is research only and does not implement migrations, schemas, contexts, Repo queries, cart behavior, order behavior, upload behavior, or variant selection behavior.

## 2. Current UI Findings

Storefront product mock fields:

```text
name
slug
description
price
price_cents
image
alt_image
category
collection_slug
availability
sale
variants
specifications
```

Admin product mock fields:

```text
name
sku
slug
description
collection
price
cost
status
stock
updated_at
image
purchase_count
```

The UI currently shows product-level price/cost/stock, but `research/004-commerce-order-flow.md` says the customer buys a selected `product_variant` because variants can affect price, production cost, stock, and image.

## 3. Commerce Flow Implications

Recommended references:

```text
cart_items.product_variant_id
sale_order_items.product_variant_id
```

The selected variant is the sellable item. `product_id` alone is not enough for cart or order line items.

## 4. Proposed `products` Table

Recommended fields:

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

Do not put `selling_price`, `production_cost`, or `stock_quantity` on `products` in the first normalized schema. Those belong to variants.

## 5. Proposed `product_variants` Table

Recommended fields:

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

`variant_name` stays simple for now, such as `PLA Red`, `PETG Black`, `Basic kit`, or `Custom color request`. Defer option tables until real multi-attribute management is needed.

Use integer VND for `production_cost` and `selling_price`. Use integer `stock_quantity` with default `0`.

## 6. Proposed `product_images` Table

Recommended fields:

```text
id
product_id
filename
display_order
inserted_at
updated_at
```

`product_images` stores product-level gallery images. `product_variants.image_filename` stores one variant preview image. Defer `product_variant_images`.

## 7. Relationships

Recommended:

```text
products.collection_id -> collections.id
product_variants.product_id -> products.id
product_images.product_id -> products.id
```

Use `on_delete: :restrict` for `products.collection_id`; use `on_delete: :delete_all` for variants/images if product deletion is allowed before order references exist. Once order items reference variants, product/variant deletion should be restricted or replaced with archive/status behavior.

## 8. Constraints and Indexes

Recommended:

```elixir
create unique_index(:products, [:slug])
create index(:products, [:collection_id])

create index(:product_variants, [:product_id])
create index(:product_variants, [:product_id, :display_order])
create unique_index(:product_variants, [:product_id, :variant_name])
create constraint(:product_variants, :production_cost_non_negative,
         check: "production_cost >= 0")
create constraint(:product_variants, :selling_price_non_negative,
         check: "selling_price >= 0")
create constraint(:product_variants, :stock_quantity_non_negative,
         check: "stock_quantity >= 0")
create constraint(:product_variants, :display_order_non_negative,
         check: "display_order >= 0")

create index(:product_images, [:product_id])
create index(:product_images, [:product_id, :display_order])
create constraint(:product_images, :display_order_non_negative,
         check: "display_order >= 0")
```

## 9. Naming

Recommended:

```text
Product schema: CaHeoShop.Products.Product
Product context: CaHeoShop.Products
Product image schema: CaHeoShop.ProductImages.ProductImage
Product image context: CaHeoShop.ProductImages
Product variant schema: CaHeoShop.ProductVariants.ProductVariant
Product variant context: CaHeoShop.ProductVariants
```

## 10. Open Questions

- Should product status/availability be added now or deferred?
- Should SKU stay product-level, variant-level, or both?
- Should specifications become structured fields later?
- Should products be archived instead of deleted once variants appear in order items?

## 11. Final Recommendation

Keep products as identity/content records, variants as sellable records, and product images as product-level gallery records. Cart and order lines should reference `product_variant_id`.
