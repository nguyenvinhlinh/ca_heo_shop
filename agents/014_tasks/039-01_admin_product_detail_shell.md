# Task 039-01: Admin Product Detail Shell

## Filename

`039-01_admin_product_detail_shell.md`

## Goal

Create the first version of the admin product detail page.

Route:

```text id="1yd1ky"
/admin/products/:id
```

This page should display read-only information from the `Product` schema.

This task is only the shell/foundation for the future admin product detail page.

Future tasks will add:

```text id="61vq9b"
product variants table
product image preview
product images list
image selection behavior
drag-drop image ordering
delete image behavior
```

## Background

The admin products index page should link to a detail page for each product.

The product detail page will eventually become the main place for admin to inspect:

```text id="25qmp7"
base product information
product variants
product images
image ordering
```

This task only implements base product information.

## Route

Add or complete route:

```text id="1djvlf"
/admin/products/:id
```

Recommended LiveView route:

```elixir id="2c9zbn"
live "/products/:id", ProductLive.Show, :show
```

inside the existing admin scope:

```elixir id="q7sjf4"
scope "/admin", CaHeoShopWeb.Admin, as: :admin do
  pipe_through [:browser, :require_admin_user]

  live "/products", ProductLive.Index, :index
  live "/products/new", ProductLive.New, :new
  live "/products/:id", ProductLive.Show, :show
end
```

Adjust module names to match the existing project.

## Authorization Requirement

Only users with role:

```text id="7udzjr"
admin
```

can access:

```text id="j64c21"
/admin/products/:id
```

Denied users:

```text id="nso46g"
role = system
role = customer
not logged in
```

If Task 035 already protects `/admin/*`, reuse that behavior.

Do not add new authorization logic unless required by the existing LiveView auth pattern.

## Dependencies

This task depends on:

```text id="bqh5kq"
products table exists
collections table exists
Products context exists
Task 035 admin authorization exists
Task 036 admin products index page exists
Task 038 create product page exists
```

Expected schema:

```text id="zecu42"
CaHeoShop.Products.Product
```

Expected context:

```text id="uwe8hm"
CaHeoShop.Products
```

Expected collection schema:

```text id="f9lrom"
CaHeoShop.Collections.Collection
```

## Scope

Implement a read-only admin product detail page.

Likely files:

```text id="cf9pkn"
lib/ca_heo_shop/products.ex
lib/ca_heo_shop_web/router.ex
lib/ca_heo_shop_web/live/admin/product_live/show.ex
lib/ca_heo_shop_web/live/admin/product_live/show.html.heex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/show_test.exs
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text id="hm9iev"
product edit form
product delete behavior
product variants table
product variant create/edit/remove
product image preview
product images list
image upload
thumbnail rendering
copy filename button
view original image button
delete image button
drag-drop image ordering
stock adjustment
```

This task must only display product information from the `Product` schema.

## Product Information To Display

The page should display these product fields:

```text id="6rawoe"
id
collection
slug
name_vi
name_en
description_vi
description_en
inserted_at
updated_at
```

Display collection as readable text.

Collection label should prefer:

```text id="tphacu"
collection.name_vi
```

Fallback:

```text id="l9jj50"
collection.name_en
```

If both are missing, fallback to:

```text id="q33ffe"
Collection #ID
```

If the product has no collection, show:

```text id="khfq77"
No collection
```

## Page Layout Requirement

Use the existing admin layout and DaisyUI styling.

Recommended page sections:

```text id="uqy9p8"
header
product summary card
product content card
metadata card
future layout placeholder area
```

The page should include a clear title.

Recommended title:

```text id="z54ygp"
Product detail
```

Also show the product name prominently.

Prefer:

```text id="8olzqa"
name_vi
```

Fallback:

```text id="nstbz4"
name_en
```

Fallback if both are missing:

```text id="j0h8nt"
Product #ID
```

## Header Actions

Add a back link/button:

```text id="g73s90"
Back to products
```

It should navigate to:

```text id="9lgfep"
/admin/products
```

Do not add active edit/delete buttons in this task.

If the template visually needs action buttons, use only safe navigation actions:

```text id="58owar"
Back to products
```

Do not add:

```text id="lc5efs"
Edit product
Delete product
Add variant
Upload image
```

unless they are clearly disabled placeholders. Preferred: do not add them yet.

## Products Context Requirement

Update:

```text id="ml6sde"
lib/ca_heo_shop/products.ex
```

Ensure there is a function to load a product for admin detail.

Recommended function:

```elixir id="gjh1ka"
get_product!(id)
```

or, if you want a more explicit admin function:

```elixir id="2c8q7k"
get_admin_product!(id)
```

This function should preload:

```text id="yxwedw"
collection
```

Do not preload in this task:

```text id="k4lc8o"
product_variants
product_images
```

Those preloads belong to future tasks.

Recommended implementation:

```elixir id="t74tqm"
def get_admin_product!(id) do
  Product
  |> Repo.get!(id)
  |> Repo.preload(:collection)
end
```

If `get_product!/1` already exists, either update it carefully or add `get_admin_product!/1` to avoid changing existing behavior unexpectedly.

## LiveView Requirements

Create or update:

```text id="ntfzm3"
lib/ca_heo_shop_web/live/admin/product_live/show.ex
```

The LiveView should:

```text id="j5ioia"
load product by id
assign product
render product information
show not found using normal Repo.get! behavior
```

Recommended `mount/3` or `handle_params/3` behavior:

```elixir id="t9y21z"
def handle_params(%{"id" => id}, _uri, socket) do
  product = Products.get_admin_product!(id)

  {:noreply, assign(socket, :product, product)}
end
```

Use the existing project pattern for LiveView pages.

## Admin Products Index Link Requirement

Update `/admin/products` product rows to link to the new detail page.

Each product row should provide a way to open:

```text id="nw21ny"
/admin/products/:id
```

Recommended behavior:

```text id="229lae"
click product name -> open detail page
```

or add a small action link:

```text id="ddodyw"
View
```

Do not add edit/delete actions in this task.

## Empty Or Nil Field Display

The page must not crash when optional fields are nil.

Display fallback text for nil fields.

Recommended fallback:

```text id="csh5p3"
—
```

Examples:

```text id="lcrs0n"
description_vi is nil -> —
description_en is nil -> —
collection is nil -> No collection
```

## Tests

Add Products context tests.

Test admin product loading:

```text id="pqlp8z"
get_admin_product!/1 returns product
get_admin_product!/1 preloads collection
get_admin_product!/1 raises when product does not exist
```

If using existing `get_product!/1`, update the test name accordingly.

Add LiveView tests for:

```text id="66155p"
/admin/products/:id
```

### Authorization Tests

Test:

```text id="5ipobe"
admin can access /admin/products/:id
customer cannot access /admin/products/:id
system cannot access /admin/products/:id
anonymous user redirects to login
```

If Task 035 already covers route-level admin authorization, keep this test focused on this page.

### Rendering Tests

Test page renders:

```text id="2iafkz"
Product detail title
Back to products link
product id
product slug
product name_vi
product name_en
product description_vi
product description_en
collection name
inserted_at
updated_at
```

Test product without collection renders:

```text id="brht5q"
No collection
```

Test nil descriptions render safely:

```text id="xbospq"
—
```

### Index Link Tests

Update `/admin/products` tests.

Test:

```text id="bhjo7g"
product row links to /admin/products/:id
```

or:

```text id="2ebwjr"
View link opens product detail page
```

depending on the UI implementation.

## Acceptance Criteria

The task is complete when:

```text id="v06ifa"
mix test passes
/admin/products/:id route exists
/admin/products/:id is accessible by admin users
/admin/products/:id is not accessible by system users
/admin/products/:id is not accessible by customer users
/admin/products/:id is not accessible by anonymous users
/admin/products/:id displays product id
/admin/products/:id displays product slug
/admin/products/:id displays product name_vi
/admin/products/:id displays product name_en
/admin/products/:id displays product description_vi
/admin/products/:id displays product description_en
/admin/products/:id displays collection name
/admin/products/:id displays No collection when collection_id is nil
/admin/products/:id displays inserted_at
/admin/products/:id displays updated_at
/admin/products/:id has Back to products link
/admin/products links each product to its detail page
no product variant table is implemented
no product image UI is implemented
no edit product behavior is implemented
no delete product behavior is implemented
```

## Notes

Keep this task small.

This task creates the product detail foundation only.

Future tasks can add:

```text id="co93rj"
039-02 product variants readonly table
039-03 product image preview and thumbnail list
039-04 product image selection behavior
039-05 product image drag-drop ordering
039-06 product image delete behavior
edit product page
delete product behavior
```
