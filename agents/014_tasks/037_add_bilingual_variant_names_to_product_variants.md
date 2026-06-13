# Task 037: Add Bilingual Variant Names To Product Variants

## Filename

`037_add_bilingual_variant_names_to_product_variants.md`

## Goal

Add Vietnamese and English variant name fields to the existing `product_variants` table.

Add:

```text id="i77g04"
variant_name_vi
variant_name_en
```

Example:

```text id="114f0i"
variant_name_vi: PLA Đỏ
variant_name_en: Red PLA
```

This task should update:

```text id="y0tfzo"
database migration
ProductVariant schema
Products context
seed data
database model documentation
tests
```

## Background

The existing `product_variants` table currently has:

```text id="fxgitr"
variant_name
```

This task adds bilingual variant names.

Do not remove the existing `variant_name` column yet.

Recommended transition:

```text id="8md9cw"
variant_name     -> legacy/internal fallback
variant_name_vi  -> Vietnamese display name
variant_name_en  -> English display name
```

Future UI and display logic should prefer:

```text id="lxb6v0"
variant_name_vi
variant_name_en
```

but old code can continue using:

```text id="x9j80b"
variant_name
```

until later cleanup tasks.

## Scope

Implement:

```text id="ntz3gp"
priv/repo/migrations/*_add_bilingual_names_to_product_variants.exs
lib/ca_heo_shop/products/product_variant.ex
lib/ca_heo_shop/products.ex
priv/repo/seeds.exs
012_database-model.md
test/ca_heo_shop/products_test.exs
```

Also update any product variant fixtures used by tests.

## Do Not Implement

Do not implement:

```text id="npn0pp"
admin variant form UI
storefront variant picker UI
admin products index UI changes
variant translation management UI
remove old variant_name column
rename old variant_name column
cart behavior changes
sale order snapshot changes
```

This task is only for adding bilingual variant name data and updating schema, context, seed data, documentation, and tests.

## Migration Requirements

Create a migration that alters:

```text id="ui4a5u"
product_variants
```

Add columns:

```elixir id="c2f5z2"
alter table(:product_variants) do
  add :variant_name_vi, :string
  add :variant_name_en, :string
end
```

Backfill existing rows from the legacy `variant_name` field:

```elixir id="znyh00"
execute """
UPDATE product_variants
SET
  variant_name_vi = variant_name,
  variant_name_en = variant_name
WHERE variant_name IS NOT NULL
"""
```

After backfill, enforce non-null if the existing data allows it:

```elixir id="5aklrp"
alter table(:product_variants) do
  modify :variant_name_vi, :string, null: false
  modify :variant_name_en, :string, null: false
end
```

Recommended direction:

```text id="mq290t"
database: variant_name_vi and variant_name_en are not null after backfill
schema: variant_name_vi and variant_name_en are required
```

If local data contains incomplete rows and migration fails, fix the data rather than keeping the model loose.

## Index Requirements

Keep the existing unique index on:

```text id="nfaiva"
product_id
variant_name
```

Do not remove it in this task.

Add unique indexes for the new bilingual names:

```elixir id="uiv22k"
create unique_index(:product_variants, [:product_id, :variant_name_vi],
         name: :product_variants_product_id_variant_name_vi_index
       )

create unique_index(:product_variants, [:product_id, :variant_name_en],
         name: :product_variants_product_id_variant_name_en_index
       )
```

Reason:

```text id="kvgmbs"
A product should not have two variants with the same Vietnamese name.
A product should not have two variants with the same English name.
```

The same variant name can exist under different products.

## Schema Requirements

Update:

```text id="n7m7pk"
lib/ca_heo_shop/products/product_variant.ex
```

Add fields:

```elixir id="1q71m5"
field :variant_name_vi, :string
field :variant_name_en, :string
```

Keep existing field:

```elixir id="mvx0fl"
field :variant_name, :string
```

Do not remove:

```text id="s3ryb8"
variant_name
```

## Changeset Requirements

Update the ProductVariant changeset cast list.

Expected cast fields:

```elixir id="zxksjd"
[
  :product_id,
  :variant_name,
  :variant_name_vi,
  :variant_name_en,
  :production_cost,
  :selling_price,
  :stock_quantity,
  :image_filename,
  :display_order
]
```

Expected required fields:

```elixir id="adap8a"
[
  :product_id,
  :variant_name,
  :variant_name_vi,
  :variant_name_en,
  :production_cost,
  :selling_price,
  :stock_quantity,
  :display_order
]
```

## Legacy Variant Name Behavior

Keep `variant_name` required for now.

To reduce duplicate data entry, the changeset should populate `variant_name` automatically when it is missing.

Recommended behavior:

```text id="yutrph"
if variant_name exists, keep it
if variant_name is missing and variant_name_vi exists, use variant_name_vi
if variant_name is missing and variant_name_vi is missing but variant_name_en exists, use variant_name_en
```

Recommended helper:

```elixir id="7zgsis"
defp put_legacy_variant_name(changeset) do
  variant_name = get_field(changeset, :variant_name)
  variant_name_vi = get_field(changeset, :variant_name_vi)
  variant_name_en = get_field(changeset, :variant_name_en)

  cond do
    present_string?(variant_name) ->
      changeset

    present_string?(variant_name_vi) ->
      put_change(changeset, :variant_name, String.trim(variant_name_vi))

    present_string?(variant_name_en) ->
      put_change(changeset, :variant_name, String.trim(variant_name_en))

    true ->
      changeset
  end
end

defp present_string?(value) when is_binary(value), do: String.trim(value) != ""
defp present_string?(_), do: false
```

Call this helper before:

```elixir id="fji92k"
validate_required(...)
```

## Validation Requirements

Validate required fields:

```elixir id="wjnfdd"
validate_required([
  :product_id,
  :variant_name,
  :variant_name_vi,
  :variant_name_en,
  :production_cost,
  :selling_price,
  :stock_quantity,
  :display_order
])
```

Validate length:

```elixir id="wuvqr8"
validate_length(:variant_name, max: 160)
validate_length(:variant_name_vi, max: 160)
validate_length(:variant_name_en, max: 160)
```

Keep existing numeric validations:

```text id="wcdva3"
production_cost >= 0
selling_price >= 0
stock_quantity >= 0
display_order >= 0
```

Add constraints:

```elixir id="xdelss"
unique_constraint(:variant_name,
  name: :product_variants_product_id_variant_name_index
)

unique_constraint(:variant_name_vi,
  name: :product_variants_product_id_variant_name_vi_index
)

unique_constraint(:variant_name_en,
  name: :product_variants_product_id_variant_name_en_index
)
```

Keep existing constraints for:

```text id="q9dfxm"
product_id foreign key
production_cost
selling_price
stock_quantity
display_order
```

## Products Context Requirements

Update:

```text id="jdrr3f"
lib/ca_heo_shop/products.ex
```

Ensure these functions accept and persist the new fields:

```elixir id="x91c8o"
create_product_variant(attrs \\ %{})
update_product_variant(%ProductVariant{} = product_variant, attrs)
change_product_variant(%ProductVariant{} = product_variant, attrs \\ %{})
```

No new context should be created.

Keep using:

```text id="bypzn0"
CaHeoShop.Products
```

Do not create:

```text id="5g1k1l"
CaHeoShop.ProductVariants
```

## Seed Data Requirements

Update:

```text id="adteyt"
priv/repo/seeds.exs
```

Any seeded product variants must include:

```text id="ujpyne"
variant_name
variant_name_vi
variant_name_en
```

Example:

```elixir id="dgxwe6"
Products.create_product_variant(%{
  product_id: product.id,
  variant_name: "PLA Đỏ",
  variant_name_vi: "PLA Đỏ",
  variant_name_en: "Red PLA",
  production_cost: 25_000,
  selling_price: 50_000,
  stock_quantity: 10,
  image_filename: nil,
  display_order: 0
})
```

Recommended example variants:

```text id="1bv8uw"
variant_name: PLA Đỏ
variant_name_vi: PLA Đỏ
variant_name_en: Red PLA
```

```text id="315nlq"
variant_name: PLA Đen
variant_name_vi: PLA Đen
variant_name_en: Black PLA
```

```text id="5o2tgt"
variant_name: PLA Trắng
variant_name_vi: PLA Trắng
variant_name_en: White PLA
```

Seed data must remain idempotent.

Running this multiple times should not create duplicated variants:

```bash id="ryy7hu"
mix run priv/repo/seeds.exs
```

Recommended lookup identity for product variant seeds:

```text id="i94sqn"
product_id + variant_name_vi
```

or:

```text id="3h969w"
product_id + variant_name
```

Do not identify variants by only the variant name globally, because two products may share the same variant names.

## Fixture Requirements

Update product variant fixtures used in tests.

Example:

```elixir id="jjw2ma"
def product_variant_fixture(attrs \\ %{}) do
  product = attrs[:product] || product_fixture()

  valid_attrs = %{
    product_id: product.id,
    variant_name: "PLA Đỏ",
    variant_name_vi: "PLA Đỏ",
    variant_name_en: "Red PLA",
    production_cost: 25_000,
    selling_price: 50_000,
    stock_quantity: 10,
    image_filename: nil,
    display_order: 0
  }

  {:ok, product_variant} =
    attrs
    |> Enum.into(valid_attrs)
    |> Products.create_product_variant()

  product_variant
end
```

## Database Model Documentation Requirement

Update:

```text id="29czk2"
012_database-model.md
```

The document currently describes `product_variants` with the legacy field:

```text id="lu5y2d"
variant_name
```

Update the `product_variants` fields section.

Expected updated field list:

```text id="shghvq"
id
product_id
variant_name
variant_name_vi
variant_name_en
production_cost
selling_price
stock_quantity
image_filename
display_order
inserted_at
updated_at
```

Keep `variant_name` documented as a legacy/internal fallback field for now.

Add note:

```text id="y6wplz"
variant_name is kept temporarily for backward compatibility.
New UI and future display logic should prefer variant_name_vi and variant_name_en.
```

## Database Model Summary Update

In `012_database-model.md`, update the `product_variants` summary if needed.

Current purpose may be:

```text id="0g7r80"
Sellable product options with price, cost, stock, image.
```

Update to:

```text id="hdka7b"
Sellable bilingual product options with price, cost, stock, and image.
```

## Database Model Key Decisions Update

In `012_database-model.md`, add a key decision:

```text id="kzxyh6"
Product variants support bilingual display names through variant_name_vi and variant_name_en.
```

Keep the existing key decision:

```text id="xhtw9n"
The customer buys a selected product_variant, not a generic product.
```

## Tests

Add or update Products context tests.

### Schema And Create Tests

Test:

```text id="0bz1p6"
product variant has variant_name_vi
product variant has variant_name_en
create_product_variant/1 creates variant with variant_name_vi and variant_name_en
create_product_variant/1 requires variant_name_vi
create_product_variant/1 requires variant_name_en
create_product_variant/1 keeps legacy variant_name
create_product_variant/1 can populate legacy variant_name from variant_name_vi when missing
create_product_variant/1 can populate legacy variant_name from variant_name_en when variant_name and variant_name_vi are missing
```

### Update Tests

Test:

```text id="qfysud"
update_product_variant/2 updates variant_name_vi
update_product_variant/2 updates variant_name_en
```

### Validation Tests

Test:

```text id="mnz5op"
variant_name_vi rejects values longer than 160 characters
variant_name_en rejects values longer than 160 characters
```

### Unique Constraint Tests

Test:

```text id="p6fuus"
variant_name_vi must be unique per product
variant_name_en must be unique per product
same variant_name_vi can exist under different products
same variant_name_en can exist under different products
```

### Existing Behavior Tests

Test:

```text id="99d7jw"
list_product_variants/1 still returns variants
list_product_variants/1 still orders by display_order then inserted_at
```

## Acceptance Criteria

The task is complete when:

```text id="3mpakg"
mix ecto.migrate works
mix test passes
product_variants.variant_name_vi exists
product_variants.variant_name_en exists
existing product_variants rows are backfilled from variant_name
ProductVariant schema includes variant_name_vi
ProductVariant schema includes variant_name_en
ProductVariant changeset casts variant_name_vi
ProductVariant changeset casts variant_name_en
ProductVariant changeset validates variant_name_vi
ProductVariant changeset validates variant_name_en
Products context can create variants with variant_name_vi and variant_name_en
Products context can update variants with variant_name_vi and variant_name_en
existing variant_name is not removed
variant_name can be populated from variant_name_vi when missing
seed data includes variant_name_vi and variant_name_en
seed data remains idempotent
012_database-model.md is updated
012_database-model.md documents product_variants.variant_name_vi
012_database-model.md documents product_variants.variant_name_en
012_database-model.md keeps variant_name as legacy/internal fallback
012_database-model.md explains that new display logic should prefer variant_name_vi and variant_name_en
```

## Notes

Keep this task focused on bilingual variant names.

Do not remove the legacy `variant_name` column yet.

Future tasks can decide whether to:

```text id="oqc7q5"
remove variant_name
update admin products page to display variant_name_vi and variant_name_en
update storefront variant picker
update admin variant forms
update sale order item snapshots
add variant_name_vi_snapshot
add variant_name_en_snapshot
```
