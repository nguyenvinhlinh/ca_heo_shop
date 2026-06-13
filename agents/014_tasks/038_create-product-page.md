# Task 038: Create Product Page

## Filename

`038_create_product_page.md`

## Goal

Build the admin feature for creating a new product record in the `products` table.

This task only creates the base product.

A product in this task includes:

```text id="9mzu8o"
collection_id
slug
name_vi
name_en
description_vi
description_en
```

This task must not create:

```text id="4uz884"
product variants
product images
thumbnail records
image upload behavior
```

Product variants and product images are separate workflows and must be handled by future tasks.

## Background

The product catalog is split into separate concepts:

```text id="rmv6wz"
products          -> base product identity and content
product_variants -> sellable options, stock, cost, selling price
product_images   -> product gallery images
```

This task only works with:

```text id="brj1ak"
products
```

## Route

Add or complete the admin route:

```text id="iaxi8g"
/admin/products/new
```

This page should allow an admin user to create a product.

After successful creation, redirect to either:

```text id="p6c2l5"
/admin/products
```

or:

```text id="gty3a5"
/admin/products/:id
```

If there is no admin product show page yet, redirect to:

```text id="sny0px"
/admin/products
```

## Authorization Requirement

Only users with role:

```text id="8e3391"
admin
```

can access:

```text id="sbuu68"
/admin/products/new
```

Denied users:

```text id="lx0ru8"
role = system
role = customer
not logged in
```

If Task 035 already protects `/admin/*`, reuse that behavior.

Do not add new authorization behavior in this task unless required by the existing LiveView auth pattern.

## Dependencies

This task depends on:

```text id="7nbqwe"
products table exists
collections table exists
Products context exists
Task 035 admin authorization exists
```

Expected schema:

```text id="dn8fhe"
CaHeoShop.Products.Product
```

Expected context:

```text id="1sow3h"
CaHeoShop.Products
```

Expected collection schema:

```text id="ighnlr"
CaHeoShop.Collections.Collection
```

Expected collection context:

```text id="s3b6d2"
CaHeoShop.Collections
```

## Scope

Implement product creation UI and behavior.

Likely files:

```text id="v40vph"
lib/ca_heo_shop/products.ex
lib/ca_heo_shop/products/product.ex
lib/ca_heo_shop_web/live/admin/product_live/new.ex
lib/ca_heo_shop_web/live/admin/product_live/form_component.ex
lib/ca_heo_shop_web/router.ex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/new_test.exs
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text id="z3j5fb"
create product variant
create product image
upload product image
generate thumbnail
variant stock
variant cost
variant selling price
product gallery
edit product
delete product
admin product show page
```

This task must stay focused on creating a row in the `products` table.

## Product Fields

The create product form should support:

```text id="xl7k9z"
collection_id
slug
name_vi
name_en
description_vi
description_en
```

Field behavior:

```text id="89tasw"
collection_id can be nil
slug is required
name_vi is required
name_en is required
description_vi can be nil
description_en can be nil
```

## Collection Field

The form should allow selecting a collection.

Options should include:

```text id="3m1h2u"
No collection
existing collections
```

`No collection` should save:

```text id="xh6qoc"
collection_id = nil
```

Collection option labels should prefer:

```text id="uocbnk"
name_vi
```

Fallback:

```text id="hkpg5q"
name_en
```

If both are missing, fallback to:

```text id="ljuk5h"
Collection #ID
```

Collection options should be ordered by:

```text id="8qujei"
nav_display_order ascending
name_vi ascending
name_en ascending
```

If `nav_display_order` does not exist, order by name fields only.

## Slug Requirement

The product form should include a `slug` input.

Slug rules:

```text id="f094r4"
required
unique
lowercase
URL-friendly
```

Recommended validation:

```text id="xs6pri"
only lowercase letters, numbers, and hyphens
```

Recommended regex:

```elixir id="94fu1r"
~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/
```

Invalid examples:

```text id="5818xz"
Universal Phone Stand
universal_phone_stand
universal phone stand
universal--phone-stand
```

Valid examples:

```text id="equ46y"
universal-phone-stand
pla-red-phone-holder
ssd-frame
```

Do not implement automatic slug generation in this task unless it already exists.

The admin can type the slug manually.

Automatic slug generation can be a future task.

## Products Context Requirements

Update:

```text id="0g97wp"
lib/ca_heo_shop/products.ex
```

Ensure the context has:

```elixir id="9xgrhq"
create_product(attrs \\ %{})
change_product(%Product{} = product, attrs \\ %{})
```

If these functions already exist, reuse them.

If they do not exist, add them.

Expected behavior:

```text id="q92qqd"
create_product/1 inserts a product
create_product/1 validates required fields
create_product/1 returns {:ok, product} on success
create_product/1 returns {:error, changeset} on failure
change_product/2 returns a changeset
```

Do not add product variant or product image logic to `create_product/1`.

## Product Schema Requirements

Update:

```text id="y75ruq"
lib/ca_heo_shop/products/product.ex
```

Expected fields:

```elixir id="100ida"
field :slug, :string
field :name_vi, :string
field :name_en, :string
field :description_vi, :string
field :description_en, :string

belongs_to :collection, CaHeoShop.Collections.Collection
```

If these already exist, do not duplicate them.

Expected changeset cast fields:

```elixir id="x8wary"
[
  :collection_id,
  :slug,
  :name_vi,
  :name_en,
  :description_vi,
  :description_en
]
```

Expected required fields:

```elixir id="6gyjje"
[
  :slug,
  :name_vi,
  :name_en
]
```

Expected validations:

```elixir id="9n1nif"
validate_required([:slug, :name_vi, :name_en])
validate_format(:slug, ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/)
validate_length(:slug, max: 160)
validate_length(:name_vi, max: 255)
validate_length(:name_en, max: 255)
```

Expected constraints:

```elixir id="gokl5g"
unique_constraint(:slug)
foreign_key_constraint(:collection_id)
```

If a unique index for `products.slug` does not exist yet, add it in a separate migration only if needed for this task.

## LiveView Requirements

Create or update the admin new product LiveView.

Route:

```text id="2zaq3r"
/admin/products/new
```

The page should render a product form.

Recommended title:

```text id="0dopsf"
New product
```

Required form fields:

```text id="63q9eo"
Collection
Slug
Vietnamese name
English name
Vietnamese description
English description
```

Required buttons:

```text id="m29aj4"
Create product
Cancel
```

Cancel should navigate back to:

```text id="u8k9d5"
/admin/products
```

## Form Behavior

When form is submitted with valid data:

```text id="icwz19"
create product
show success flash
redirect to /admin/products
```

Recommended success flash:

```text id="v7kbr5"
Product created successfully.
```

When form is submitted with invalid data:

```text id="v5i77p"
stay on the form
show validation errors
do not insert product
```

## UI Requirement

Use the existing admin layout and DaisyUI styling.

The form should be clean and simple.

Do not add product image upload UI.

Do not add variant creation UI.

Do not add stock/cost/price fields.

These fields belong to product variants, not products:

```text id="jg2jgp"
variant_name
stock_quantity
production_cost
selling_price
image_filename
```

They must not appear on this create product form.

## Admin Products Index Link

If `/admin/products` already has a “New product” button, wire it to:

```text id="8ctjyp"
/admin/products/new
```

If the button does not exist, add one.

Button label:

```text id="150kng"
New product
```

Do not add buttons for:

```text id="5qwjkh"
New variant
Upload image
Bulk action
Export CSV
```

## Tests

Add Products context tests.

Test successful creation:

```text id="168l9w"
create_product/1 creates a product with valid attrs
```

Test required fields:

```text id="vveqor"
create_product/1 requires slug
create_product/1 requires name_vi
create_product/1 requires name_en
```

Test optional fields:

```text id="mx4zkb"
create_product/1 allows nil collection_id
create_product/1 allows nil description_vi
create_product/1 allows nil description_en
```

Test constraints:

```text id="6bs4j0"
create_product/1 rejects duplicate slug
create_product/1 rejects invalid collection_id
```

Test slug validation:

```text id="0wavkz"
create_product/1 accepts lowercase hyphen slug
create_product/1 rejects slug with spaces
create_product/1 rejects slug with underscore
create_product/1 rejects uppercase slug
create_product/1 rejects repeated hyphen pattern if regex enforces it
```

Add LiveView tests for:

```text id="xfkz94"
/admin/products/new
```

Test authorization:

```text id="5tn8tg"
admin can access /admin/products/new
customer cannot access /admin/products/new
system cannot access /admin/products/new
anonymous user redirects to login
```

Test rendering:

```text id="8msz1a"
renders New product title
renders collection select
renders slug input
renders name_vi input
renders name_en input
renders description_vi input
renders description_en input
renders Create product button
does not render variant fields
does not render image upload fields
does not render stock field
does not render production cost field
does not render selling price field
```

Test valid submit:

```text id="7mfw1g"
submitting valid form creates product
redirects to /admin/products
shows success flash
```

Test invalid submit:

```text id="z7qn3w"
submitting invalid form shows validation errors
does not create product
```

## Acceptance Criteria

The task is complete when:

```text id="yi512i"
mix test passes
/admin/products/new exists
/admin/products/new is accessible by admin users
/admin/products/new is not accessible by system users
/admin/products/new is not accessible by customer users
/admin/products/new is not accessible by anonymous users
admin can create a product
created product is inserted into products table
product can be created without collection
product requires slug
product requires name_vi
product requires name_en
product slug is unique
product slug is URL-friendly
form includes collection_id
form includes slug
form includes name_vi
form includes name_en
form includes description_vi
form includes description_en
form does not include product variant fields
form does not include stock field
form does not include production cost field
form does not include selling price field
form does not include product image upload
successful create redirects to /admin/products
/admin/products has a New product link or button
```

## Notes

Keep this task narrow.

This task creates only the base product record.

A product is not yet sellable until it has variants.

Future tasks can add:

```text id="p4x6ag"
create product variant
edit product
delete product
upload product images
generate thumbnails
product detail admin page
storefront product visibility
automatic slug generation
```
