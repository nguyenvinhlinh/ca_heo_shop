# Task 039-02: Admin Product Variants Readonly Table

## Filename

`039-02_admin_product_variants_readonly_table.md`

## Goal

Add a readonly product variants table to the admin product detail page.

Target page:

```text id="h2qww7"
/admin/products/:id
```

The variants table should be displayed on the left side of the product detail layout.

This task only shows existing product variants.

It must not implement create, edit, remove, stock adjustment, or variant image behavior.

## Background

Task `039-01` created the admin product detail shell.

This task extends that page by showing variants that belong to the current product.

Relationship:

```text id="as9c6h"
products has many product_variants
product_variants belongs to product
```

Expected schema:

```text id="8ybr68"
CaHeoShop.Products.ProductVariant
```

Expected context:

```text id="z0u6yw"
CaHeoShop.Products
```

## Route

Use the existing product detail route:

```text id="qk3esf"
/admin/products/:id
```

Do not create a new route for this task.

## Authorization Requirement

Only users with role:

```text id="rt0yam"
admin
```

can access:

```text id="h2wlg7"
/admin/products/:id
```

If Task 035 already protects `/admin/*`, reuse that behavior.

Do not add new authorization logic in this task.

## Dependencies

This task depends on:

```text id="yd2mqq"
Task 032: product_variants table exists
Task 035: admin route authorization exists
Task 039-01: admin product detail shell exists
```

Expected schemas:

```text id="2t9oqt"
CaHeoShop.Products.Product
CaHeoShop.Products.ProductVariant
```

Expected association:

```elixir id="p56v6u"
has_many :product_variants, CaHeoShop.Products.ProductVariant
```

on:

```text id="np6r77"
CaHeoShop.Products.Product
```

## Scope

Update the admin product detail page to include a readonly variants table.

Likely files:

```text id="wceui7"
lib/ca_heo_shop/products.ex
lib/ca_heo_shop_web/live/admin/product_live/show.ex
lib/ca_heo_shop_web/live/admin/product_live/show.html.heex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/show_test.exs
```

Actual file names may differ depending on the project structure.

## Do Not Implement

Do not implement:

```text id="5osju9"
create product variant
edit product variant
remove product variant
delete product variant
variant form
variant modal
stock adjustment
variant image upload
product image preview
product images list
image drag-drop ordering
```

The `edit` and `remove` buttons in this task are static UI only.

They should not trigger any event.

They should not navigate anywhere.

They should not mutate data.

## Products Context Requirement

Update:

```text id="kz0u1s"
lib/ca_heo_shop/products.ex
```

Ensure the admin product detail loader preloads product variants.

Recommended function:

```elixir id="in9i0d"
get_admin_product!(id)
```

Expected preload:

```text id="w83rx1"
collection
product_variants
```

Product variants should be ordered by:

```text id="7d8w1k"
display_order ascending
inserted_at ascending
```

Recommended helper:

```elixir id="frwqa8"
defp product_variants_order_query do
  from pv in ProductVariant,
    order_by: [asc: pv.display_order, asc: pv.inserted_at]
end
```

Recommended implementation shape:

```elixir id="mml05c"
def get_admin_product!(id) do
  Product
  |> Repo.get!(id)
  |> Repo.preload([
    :collection,
    product_variants: product_variants_order_query()
  ])
end
```

If `get_admin_product!/1` already exists from Task `039-01`, update it carefully.

Do not preload product images in this task.

Product image preload belongs to future image tasks.

## UI Layout Requirement

Update the product detail page layout so the left side contains:

```text id="h7nfs7"
product information
product variants table
```

The right side can remain empty or reserved for future image work.

Do not implement image UI in this task.

Recommended layout direction:

```text id="f55wij"
left column  -> product info + variants
right column -> future image area placeholder, or no content yet
```

Do not overbuild the right side.

## Variants Table Requirement

Add a section title:

```text id="5l5ajj"
Product variants
```

Render a table listing all variants for the current product.

The table should include columns based on the `ProductVariant` schema.

Required columns:

```text id="4fwp2r"
display_order
variant name
production_cost
selling_price
stock_quantity
image_filename
inserted_at or updated_at
actions
```

If the project already has bilingual variant name fields, display:

```text id="t9pkg4"
variant_name_vi
variant_name_en
```

If bilingual variant name fields do not exist, display:

```text id="tlxo11"
variant_name
```

Recommended flexible column set:

```text id="6f17ij"
Order
Variant
Cost
Price
Stock
Image filename
Updated
Actions
```

If bilingual fields exist:

```text id="w2skbd"
Order
Variant VI
Variant EN
Cost
Price
Stock
Image filename
Updated
Actions
```

## Static Action Buttons

The last column of each variant row must contain two static buttons:

```text id="nbjlmr"
edit
remove
```

These buttons are placeholders only.

They must not have real behavior.

Acceptable implementation:

```heex id="63pise"
<button type="button" class="btn btn-xs" disabled>Edit</button>
<button type="button" class="btn btn-xs btn-error" disabled>Remove</button>
```

or static non-disabled buttons with no event handlers.

Preferred:

```text id="jk8ivl"
disabled buttons
```

Reason:

```text id="7okqrx"
The feature is planned for later, but should not appear functional yet.
```

Do not add:

```text id="deovps"
phx-click
patch
navigate
href
data-confirm
```

to these buttons.

## Empty State

If the product has no variants, show:

```text id="wbwypq"
No variants
```

The page must not crash when:

```text id="y2zg7i"
product has no variants
variant image_filename is nil
variant production_cost is 0
variant selling_price is 0
variant stock_quantity is 0
```

## Money Display

Display money fields as VND integer amounts.

Fields:

```text id="y64ylb"
production_cost
selling_price
```

Examples:

```text id="5rrj7x"
25,000 VND
50,000 VND
```

If a money formatting helper already exists, reuse it.

If no helper exists, create a small private helper in the LiveView or component.

Do not add an external money library.

## Stock Display

Display stock as an integer.

Example:

```text id="xgm3qh"
Stock: 10
```

In table column form, raw integer display is acceptable:

```text id="xske1c"
10
```

## Image Filename Display

Display `image_filename` if present.

If `image_filename` is nil, show:

```text id="4gm87o"
—
```

Do not render variant images in this task.

Only render the filename text.

## Ordering Requirement

Variants must be displayed ordered by:

```text id="fgmz0a"
display_order ascending
inserted_at ascending
```

This order should be handled at the context/query level, not by sorting only in the template.

## Tests

Add or update Products context tests.

### Context Tests

Test:

```text id="a7csx0"
get_admin_product!/1 preloads product_variants
get_admin_product!/1 orders product_variants by display_order then inserted_at
get_admin_product!/1 still preloads collection
```

If using another function name, adjust the test name accordingly.

### LiveView Rendering Tests

Add tests for:

```text id="o9j56e"
/admin/products/:id
```

Test page renders:

```text id="n55bxj"
Product variants section title
variant name
production_cost
selling_price
stock_quantity
image_filename
display_order
edit button
remove button
```

If bilingual variant names exist, test rendering:

```text id="9kfvf7"
variant_name_vi
variant_name_en
```

Otherwise test rendering:

```text id="bq7ejh"
variant_name
```

Test empty state:

```text id="neubmk"
product without variants renders No variants
```

Test nil image filename:

```text id="rp0yfw"
variant with nil image_filename renders —
```

Test static buttons:

```text id="x8pqb9"
edit button is rendered
remove button is rendered
edit button does not have phx-click
remove button does not have phx-click
```

### Authorization Tests

If Task 039-01 already has page authorization tests, do not duplicate too much.

At minimum, keep or verify:

```text id="7tctno"
admin can access /admin/products/:id
customer cannot access /admin/products/:id
system cannot access /admin/products/:id
anonymous user redirects to login
```

## Acceptance Criteria

The task is complete when:

```text id="hnzmeu"
mix test passes
/admin/products/:id still works
/admin/products/:id displays Product variants section
product variants are loaded from database
product variants are shown only for the current product
product variants are ordered by display_order then inserted_at
variant production_cost is displayed
variant selling_price is displayed
variant stock_quantity is displayed
variant image_filename is displayed as text
nil image_filename displays —
product with no variants displays No variants
each variant row has edit button
each variant row has remove button
edit button has no behavior
remove button has no behavior
no variant create behavior is implemented
no variant edit behavior is implemented
no variant remove behavior is implemented
no product image UI is implemented
```

## Notes

Keep this task small.

This task only adds a readonly variants table to the product detail page.

Future tasks can add:

```text id="e4pr6w"
039-03 product image preview and thumbnail list
039-04 product image selection behavior
039-05 product image drag-drop ordering
039-06 product image delete behavior
create product variant
edit product variant
remove product variant
stock adjustment
```
