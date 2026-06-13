# Task 032: Create Product Variants Table

## Goal

Create the `product_variants` table for sellable product options.

A product variant represents the actual option that a customer can buy, such as:

```text
Product: Universal Phone Stand
Variant: PLA Red
Price: 50,000 VND
````

Follow `012_database-model.md`:

```text
Table: product_variants
Schema: CaHeoShop.Products.ProductVariant
Context: CaHeoShop.Products
```

Do not create a separate `ProductVariants` context.

## Background

The database model says:

```text
product_variants.product_id -> products.id
```

The customer should buy a selected `product_variant`, not only a generic product.

Variants can affect:

```text
price
production cost
stock quantity
display image
```

This table will later be referenced by:

```text
cart_items.product_variant_id
sale_order_items.product_variant_id
inventory_movements.product_variant_id
```

## Scope

Implement:

```text
priv/repo/migrations/*_create_product_variants.exs
lib/ca_heo_shop/products/product_variant.ex
lib/ca_heo_shop/products/product.ex
lib/ca_heo_shop/products.ex
test/ca_heo_shop/products_test.exs
```

Do not implement:

```text
cart_items
sale_order_items
inventory_movements
admin UI
storefront UI
image upload behavior
thumbnail generation
variant image gallery
```

## Migration Requirements

Create table:

```text
product_variants
```

Fields:

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

Recommended Ecto migration shape:

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
```

Use integer money amounts for VND.

Do not use float for money.

Add indexes:

```elixir
create index(:product_variants, [:product_id])
create index(:product_variants, [:product_id, :display_order])

create unique_index(:product_variants, [:product_id, :variant_name],
         name: :product_variants_product_id_variant_name_index
       )
```

Add database check constraints:

```elixir
create constraint(:product_variants, :product_variants_production_cost_non_negative,
         check: "production_cost >= 0"
       )

create constraint(:product_variants, :product_variants_selling_price_non_negative,
         check: "selling_price >= 0"
       )

create constraint(:product_variants, :product_variants_stock_quantity_non_negative,
         check: "stock_quantity >= 0"
       )

create constraint(:product_variants, :product_variants_display_order_non_negative,
         check: "display_order >= 0"
       )
```

## Schema Requirements

Create schema:

```text
CaHeoShop.Products.ProductVariant
```

File:

```text
lib/ca_heo_shop/products/product_variant.ex
```

Schema fields:

```elixir
field :variant_name, :string
field :production_cost, :integer, default: 0
field :selling_price, :integer
field :stock_quantity, :integer, default: 0
field :image_filename, :string
field :display_order, :integer, default: 0

belongs_to :product, CaHeoShop.Products.Product

timestamps(type: :utc_datetime)
```

Changeset should cast:

```elixir
[
  :product_id,
  :variant_name,
  :production_cost,
  :selling_price,
  :stock_quantity,
  :image_filename,
  :display_order
]
```

Required fields:

```elixir
[
  :product_id,
  :variant_name,
  :production_cost,
  :selling_price,
  :stock_quantity,
  :display_order
]
```

Validations:

```elixir
validate_required(...)
validate_number(:production_cost, greater_than_or_equal_to: 0)
validate_number(:selling_price, greater_than_or_equal_to: 0)
validate_number(:stock_quantity, greater_than_or_equal_to: 0)
validate_number(:display_order, greater_than_or_equal_to: 0)
```

Add constraints:

```elixir
foreign_key_constraint(:product_id)

unique_constraint(:variant_name,
  name: :product_variants_product_id_variant_name_index
)

check_constraint(:production_cost,
  name: :product_variants_production_cost_non_negative
)

check_constraint(:selling_price,
  name: :product_variants_selling_price_non_negative
)

check_constraint(:stock_quantity,
  name: :product_variants_stock_quantity_non_negative
)

check_constraint(:display_order,
  name: :product_variants_display_order_non_negative
)
```

## Product Schema Update

Update:

```text
lib/ca_heo_shop/products/product.ex
```

Add association:

```elixir
has_many :product_variants, CaHeoShop.Products.ProductVariant
```

Do not rename the association to `variants` yet.

Use the explicit association name:

```text
product_variants
```

## Products Context Requirements

Update:

```text
lib/ca_heo_shop/products.ex
```

Alias:

```elixir
alias CaHeoShop.Products.ProductVariant
```

Add context functions:

```elixir
list_product_variants(product_id)
get_product_variant!(id)
create_product_variant(attrs \\ %{})
update_product_variant(%ProductVariant{} = product_variant, attrs)
delete_product_variant(%ProductVariant{} = product_variant)
change_product_variant(%ProductVariant{} = product_variant, attrs \\ %{})
```

`list_product_variants(product_id)` should return variants for one product ordered by:

```text
display_order ascending
inserted_at ascending
```

Example query shape:

```elixir
from pv in ProductVariant,
  where: pv.product_id == ^product_id,
  order_by: [asc: pv.display_order, asc: pv.inserted_at]
```

Do not add product variant behavior to `Carts`, `Sales`, or `Inventory` contexts in this task.

## Tests

Add tests for:

```text
create_product_variant/1 creates a valid variant
create_product_variant/1 requires product_id
create_product_variant/1 requires variant_name
create_product_variant/1 requires selling_price
create_product_variant/1 rejects negative production_cost
create_product_variant/1 rejects negative selling_price
create_product_variant/1 rejects negative stock_quantity
create_product_variant/1 rejects negative display_order
create_product_variant/1 enforces unique variant_name per product
list_product_variants/1 returns only variants for the given product
list_product_variants/1 orders by display_order then inserted_at
update_product_variant/2 updates editable fields
delete_product_variant/1 deletes the variant
change_product_variant/1 returns a changeset
```

Use product fixtures from the existing Products test helpers if available.

If product fixtures do not exist yet, create a minimal helper inside the test support layer, but do not overbuild a fixture system.

## Acceptance Criteria

The task is complete when:

```text
mix ecto.migrate works
mix test passes
product_variants table exists
CaHeoShop.Products.ProductVariant schema exists
CaHeoShop.Products context exposes variant CRUD functions
Product schema has has_many :product_variants
Variant money fields use integer VND amounts
Variant stock is stored at variant level
Variant display order is supported
Variant image filename is optional
No ProductVariants context is created
No UI is created
No cart/order/inventory behavior is created
```

## Notes

Keep this task focused.

`product_variants` is part of the catalog domain, so it belongs inside:

```text
CaHeoShop.Products
```

Use:

```text
CaHeoShop.Products.ProductVariant
```

Do not use:

```text
CaHeoShop.ProductVariants.ProductVariant
CaHeoShop.ProductVariants
```

Future tasks can connect variants to cart items, sale order items, and inventory movements.
