# Task 036: Admin Products Index Page

## Filename

`036_admin_products_index_page.md`

## Goal

Build the real admin products index page at:

```text
/admin/products
```

This page allows an admin user to view the product catalog in table format.

The table must show real product data from the database, including:

```text
product information
product collection
product image
product variants
variant stock
variant production cost
variant selling price
```

The page must support:

```text
pagination
select rows per page
select page number
product range summary
collection filter
product name search
```

This task replaces the current mock admin products UI.

## Dependencies

This task depends on:

```text
Task 031: product_images table exists
Task 032: product_variants table exists
Task 035: admin route authorization exists
```

Required tables:

```text
collections
products
product_images
product_variants
```

Expected schemas:

```text
CaHeoShop.Collections.Collection
CaHeoShop.Products.Product
CaHeoShop.Products.ProductImage
CaHeoShop.Products.ProductVariant
```

Expected contexts:

```text
CaHeoShop.Collections
CaHeoShop.Products
```

## Authorization Requirement

The page:

```text
/admin/products
```

must be accessible only by users with:

```text
role = admin
```

Denied users:

```text
role = system
role = customer
not logged in
```

If Task 035 already protects `/admin/*`, reuse that behavior.

Do not add new role or permission logic in this task.

## Scope

Implement the real admin products index page.

Likely files:

```text
lib/ca_heo_shop/products.ex
lib/ca_heo_shop_web/live/admin/product_live/index.ex
lib/ca_heo_shop_web/live/admin/product_live/index.html.heex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/index_test.exs
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text
create product
edit product
delete product
product image upload
product variant CRUD
collection CRUD
CSV export
bulk actions
stock adjustment
inventory movement history
```

This task is only for viewing, filtering, searching, and paginating the admin product list.

## Remove Existing Mock UI

Remove these existing mock UI elements from `/admin/products`:

```text
export mock csv
bulk action
```

Do not leave fake buttons.

Do not keep dead UI actions.

Do not keep placeholder CSV export behavior.

## Product Table Requirements

The admin products page should render a table.

Each product record should show:

```text
product image
name_vi
name_en
slug
collection
variants
updated_at or inserted_at
```

The exact visual layout can follow the existing admin template, but the data must be real.

## Product Image Requirement

Each product row should show one product image.

The image source should come from the first `ProductImage` of the product.

For this task, the first product image is defined as:

```text
product_images.display_order = 0
```

Image selection rule:

```text
1. Find ProductImage where display_order = 0.
2. If no such image exists, show a No image placeholder.
3. If image exists and has_thumbnail = true, render the thumbnail image.
4. If image exists and has_thumbnail = false, render the original image.
```

Expected `product_images` fields:

```text
filename
display_order
has_thumbnail
```

Do not use product variant images for the product table image.

The admin product table image represents the product, not a specific variant.

## Product Image Path Requirement

Use the existing product image path convention in the project.

If the project already has image URL helpers, reuse them.

Expected behavior:

```text
has_thumbnail = true  -> render thumbnail URL
has_thumbnail = false -> render original image URL
no display_order = 0 image -> render No image placeholder
```

If no thumbnail filename column exists, derive the thumbnail path using the same naming convention already used by the thumbnail generator task.

Do not invent a second thumbnail naming convention.

## Product Image UI Requirement

Add an image column to the product table.

Recommended image size:

```text
48x48
64x64
```

Use square object-cover styling.

Example behavior:

```text
product has thumbnail -> show thumbnail
product has original image only -> show original image
product has no display_order = 0 image -> show No image
```

The page must not crash when:

```text
product has no images
product has images but none with display_order = 0
product image has_thumbnail = false
product image has_thumbnail = true
```

## Variant Display Requirement

Each product row must show the product variants.

For each variant, display:

```text
variant_name
stock_quantity
production_cost
selling_price
```

Recommended display:

```text
PLA Red
Stock: 10
Cost: 25,000 VND
Price: 50,000 VND
```

If a product has multiple variants, display them as a compact list or nested mini table inside the product row.

If a product has no variants, show:

```text
No variants
```

Pagination must be based on products, not variants.

## Money Display

Display money fields as VND integer amounts.

Examples:

```text
25,000 VND
50,000 VND
```

Do not display raw unformatted integers if a formatting helper already exists.

If no formatting helper exists, create a small private helper in the LiveView or view layer.

Do not introduce an external money library in this task.

## Pagination Requirements

The page must support pagination.

Required query params:

```text
page
per_page
```

Default values:

```text
page = 1
per_page = 20
```

Supported `per_page` options:

```text
20
50
100
```

Normalize invalid params safely.

Examples:

```text
page < 1 -> page = 1
invalid page -> page = 1
unsupported per_page -> per_page = 20
```

The UI must support:

```text
previous page
next page
select page number
select records per page
```

The user should be able to choose which page to view.

The user should be able to choose how many table records to show per page.

## Pagination Summary Text

Show a clear summary of the current product range.

Example:

```text
Showing products 1-20 of 137
```

For page 2 with 20 records per page:

```text
Showing products 21-40 of 137
```

If there are zero products, show:

```text
Showing products 0-0 of 0
```

The summary must count products, not variants.

## Collection Filter Requirements

The page must support filtering products by collection.

Required query param:

```text
collection
```

Supported values:

```text
ALL
NULL
<collection_id>
```

Meaning:

```text
ALL  -> show products from all collections
NULL -> show products that do not belong to any collection
id   -> show products that belong to the selected collection
```

The filter dropdown should include:

```text
ALL
NULL
all existing collections
```

Recommended labels:

```text
ALL - All collections
NULL - No collection
<collection name>
```

For collection names, prefer:

```text
name_vi
```

Fallback:

```text
name_en
```

If both are missing, fallback to:

```text
Collection #ID
```

Collection options should be ordered by:

```text
nav_display_order ascending
name_vi ascending
name_en ascending
```

If the existing collections schema does not have `nav_display_order`, order by name fields.

## Product Search Requirements

The page must support searching products by product name.

Required query param:

```text
q
```

Search these columns:

```text
products.name_vi
products.name_en
```

Search behavior:

```text
case-insensitive partial match
trim surrounding spaces
empty search behaves like no search
```

Recommended query behavior:

```elixir
where:
  ilike(p.name_vi, ^"%#{q}%") or
  ilike(p.name_en, ^"%#{q}%")
```

This task only searches by product name.

Do not search by variant name in this task.

Do not implement accent-insensitive Vietnamese search yet.

## Combined Filter Behavior

Pagination, search, and collection filter must work together.

Examples:

```text
/admin/products?page=1&per_page=20&collection=ALL&q=stand
/admin/products?page=2&per_page=10&collection=NULL&q=
/admin/products?page=1&per_page=50&collection=3&q=phone
```

When user changes search or collection filter, reset page to:

```text
1
```

When user changes `per_page`, reset page to:

```text
1
```

Changing only page should preserve:

```text
per_page
collection
q
```

## Products Context Requirements

Update:

```text
lib/ca_heo_shop/products.ex
```

Add an admin listing function.

Recommended function:

```elixir
list_admin_products(params \\ %{})
```

The function should return a pagination result.

Recommended return shape:

```elixir
%{
  entries: products,
  page: page,
  per_page: per_page,
  total_count: total_count,
  total_pages: total_pages,
  from: from,
  to: to
}
```

`entries` should be products preloaded with:

```text
collection
product_images
product_variants
```

Product order:

```text
inserted_at descending
id descending
```

Variant preload order:

```text
display_order ascending
inserted_at ascending
```

Product image preload order:

```text
display_order ascending
inserted_at ascending
```

The page should select the display image from preloaded `product_images` by finding:

```text
display_order = 0
```

## Suggested Query Shape

Build the query in small helper functions.

Suggested shape:

```elixir
def list_admin_products(params \\ %{}) do
  params = normalize_admin_product_params(params)

  base_query =
    Product
    |> admin_product_search_query(params.q)
    |> admin_product_collection_query(params.collection)

  total_count = Repo.aggregate(base_query, :count, :id)

  entries =
    base_query
    |> order_by([p], [desc: p.inserted_at, desc: p.id])
    |> limit(^params.per_page)
    |> offset(^((params.page - 1) * params.per_page))
    |> preload([
      :collection,
      product_images: ^product_images_order_query(),
      product_variants: ^product_variants_order_query()
    ])
    |> Repo.all()

  build_page_result(entries, params, total_count)
end
```

Collection filter helper:

```elixir
defp admin_product_collection_query(query, "ALL"), do: query

defp admin_product_collection_query(query, "NULL") do
  from p in query, where: is_nil(p.collection_id)
end

defp admin_product_collection_query(query, collection_id) do
  case Integer.parse(to_string(collection_id)) do
    {id, ""} -> from p in query, where: p.collection_id == ^id
    _ -> query
  end
end
```

Search helper:

```elixir
defp admin_product_search_query(query, q) do
  q = String.trim(to_string(q || ""))

  if q == "" do
    query
  else
    pattern = "%#{q}%"

    from p in query,
      where: ilike(p.name_vi, ^pattern) or ilike(p.name_en, ^pattern)
  end
end
```

Variant preload helper:

```elixir
defp product_variants_order_query do
  from pv in ProductVariant,
    order_by: [asc: pv.display_order, asc: pv.inserted_at]
end
```

Product image preload helper:

```elixir
defp product_images_order_query do
  from pi in ProductImage,
    order_by: [asc: pi.display_order, asc: pi.inserted_at]
end
```

Adjust code style to match the existing project.

## LiveView Requirements

The admin product LiveView should read URL params:

```text
page
per_page
collection
q
```

Use `handle_params/3` so the URL represents the current table state.

The page should support browser back/forward correctly.

Filtering, searching, and pagination controls should update the URL using:

```text
push_patch
```

or the existing project navigation helpers.

Do not store table state only in socket assigns without URL params.

Required assigns:

```text
products
page
per_page
total_count
total_pages
from
to
collection
q
collection_options
```

## UI Controls

The page should include:

```text
search input
collection filter select
per-page select
page select
previous button
next button
pagination summary text
products table
```

Search input label:

```text
Search products
```

Collection filter label:

```text
Collection
```

Per-page select label:

```text
Rows per page
```

Page select label:

```text
Page
```

Use existing DaisyUI/table styling from the admin template where possible.

## Search Form Behavior

Search form should submit or update query param:

```text
q
```

When applying search:

```text
page = 1
```

Do not require JavaScript debounce in this task.

A normal submit button is fine.

Recommended button:

```text
Search
```

## Empty State

If no products match the current filters, show:

```text
No products found.
```

The table should not crash when:

```text
no products
no variants
no collection
no product images
```

For products without collection, display:

```text
No collection
```

For products without variants, display:

```text
No variants
```

For products without a display image, display:

```text
No image
```

## Tests

Add context tests for:

```elixir
Products.list_admin_products/1
```

### Pagination Tests

Test:

```text
returns first page
returns second page
supports per_page
returns total_count
returns total_pages
returns from and to range
returns 0-0 range when no products
```

### Collection Filter Tests

Test:

```text
collection=ALL returns all products
collection=NULL returns products with nil collection_id
collection=<id> returns products in that collection only
invalid collection behaves like ALL
```

### Search Tests

Test:

```text
search by name_vi
search by name_en
search is case-insensitive
blank search returns all products
search combines with collection filter
```

### Preload Tests

Test:

```text
products include collection preload
products include product_images preload
products include product_variants preload
product_images are ordered by display_order then inserted_at
product_variants are ordered by display_order then inserted_at
```

### Product Image Tests

Test:

```text
product row uses ProductImage with display_order = 0
product row does not use ProductImage with display_order > 0 as primary image
product row uses thumbnail when has_thumbnail = true
product row uses original image when has_thumbnail = false
product row shows No image when no ProductImage with display_order = 0 exists
```

If testing exact image URLs is fragile, test for stable filename/path fragments.

## LiveView Tests

Add LiveView tests for:

```text
/admin/products
```

### Authorization Tests

Test:

```text
admin can access /admin/products
customer cannot access /admin/products
system cannot access /admin/products
anonymous user redirects to login
```

If Task 035 already covers route-level tests, only add page-specific admin access tests.

### Rendering Tests

Test the page renders:

```text
product image column
product name_vi
product name_en
product slug
collection name
No collection
variant_name
stock_quantity
production_cost
selling_price
pagination summary
rows per page selector
page selector
collection filter
search input
```

Test the page does not render:

```text
export mock csv
bulk action
```

### Filter UI Tests

Test:

```text
selecting collection filters products
selecting NULL shows products without collection
selecting ALL shows all products
searching by Vietnamese name filters products
searching by English name filters products
changing per_page updates visible row count
changing page shows another page
```

## Acceptance Criteria

The task is complete when:

```text
mix test passes
/admin/products is accessible by admin users
/admin/products is not accessible by system users
/admin/products is not accessible by customer users
/admin/products is not accessible by anonymous users
/admin/products shows real products from the database
/admin/products shows a product image column
product image comes from ProductImage with display_order = 0
thumbnail is used when has_thumbnail = true
original image is used when has_thumbnail = false
No image placeholder is shown when product has no display_order = 0 image
variant image is not used as product table image
each product record shows variants
each variant shows stock quantity
each variant shows production cost
each variant shows selling price
pagination works
rows-per-page selector works
page selector works
pagination summary shows product range and total count
collection filter includes ALL
collection filter includes NULL
collection filter includes all existing collections
collection=ALL shows all products
collection=NULL shows products without collection
collection=<id> shows products in selected collection
search works for name_vi
search works for name_en
search combines with collection filter
export mock csv UI is removed
bulk action UI is removed
empty state works
products without variants do not crash the page
products without collection do not crash the page
products without images do not crash the page
```

## Notes

Keep this task focused on the admin products index page.

This task should make `/admin/products` useful as a real product overview page.

Future tasks can add:

```text
create product
edit product
delete product
variant CRUD
stock adjustment
CSV export for real data
bulk actions for real workflows
advanced search
accent-insensitive Vietnamese search
sort by price
sort by stock
```
