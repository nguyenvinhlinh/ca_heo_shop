# Task 031: Create `product_images` table

## Goal

Create the `product_images` table for product-level gallery images.

This task adds persistence for multiple images belonging to one product.

Use the existing `Products` context instead of creating a separate `ProductImages` context.

Final module direction:

~~~elixir
CaHeoShop.Products.ProductImage
CaHeoShop.Products
~~~

Do not create:

~~~elixir
CaHeoShop.ProductImages
CaHeoShop.ProductImages.ProductImage
~~~

## Background

The product catalog should support a gallery of images for each product.

Current relationship direction:

~~~text
products has many product_images
product_images belongs to products
product_images.product_id -> products.id
~~~

`product_images` is not a separate business domain. It is part of product management, so the schema should live inside the `Products` context.

This table also prepares image records for thumbnail generation.

`ThumbnailGenerator` will later use `has_thumbnail` to find product images that still need thumbnails.

## Scope

Create:

~~~text
product_images table
CaHeoShop.Products.ProductImage schema
Products context functions for product images
basic tests
~~~

Do not create:

~~~text
image upload UI
admin product image management UI
ThumbnailGenerator implementation
thumbnail generation job
thumbnail file naming logic
variant image gallery
generic media asset table
order snapshot behavior
cart behavior
checkout behavior
~~~

## Database Table

Create migration for:

~~~text
product_images
~~~

Fields:

~~~text
id
product_id
filename
display_order
has_thumbnail
inserted_at
updated_at
~~~

Recommended migration shape:

~~~elixir
create table(:product_images) do
  add :product_id, references(:products, on_delete: :delete_all), null: false
  add :filename, :string, null: false
  add :display_order, :integer, null: false, default: 0
  add :has_thumbnail, :boolean, null: false, default: false

  timestamps(type: :utc_datetime)
end

create index(:product_images, [:product_id])
create index(:product_images, [:product_id, :display_order])
create index(:product_images, [:has_thumbnail])
~~~

## Field Meaning

### `filename`

Stores the original product image filename.

Example:

~~~text
universal-phone-stand-red.jpg
~~~

### `display_order`

Controls gallery ordering.

Lower values appear first.

Default:

~~~text
0
~~~

### `has_thumbnail`

Tracks whether a thumbnail has already been generated for this product image.

Default:

~~~text
false
~~~

Meaning:

~~~text
has_thumbnail = false
~~~

The original image exists, but thumbnail generation has not completed yet.

~~~text
has_thumbnail = true
~~~

The thumbnail has been generated successfully.

`ThumbnailGenerator` should later query images where:

~~~elixir
image.has_thumbnail == false
~~~

Then after successful thumbnail generation, it should update:

~~~elixir
has_thumbnail: true
~~~

If thumbnail generation fails, keep:

~~~elixir
has_thumbnail: false
~~~

Do not implement `ThumbnailGenerator` in this task.

## Schema

Create file:

~~~text
lib/ca_heo_shop/products/product_image.ex
~~~

Schema module:

~~~elixir
defmodule CaHeoShop.Products.ProductImage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "product_images" do
    field :filename, :string
    field :display_order, :integer, default: 0
    field :has_thumbnail, :boolean, default: false

    belongs_to :product, CaHeoShop.Products.Product

    timestamps(type: :utc_datetime)
  end

  def changeset(product_image, attrs) do
    product_image
    |> cast(attrs, [:product_id, :filename, :display_order, :has_thumbnail])
    |> validate_required([:product_id, :filename, :has_thumbnail])
    |> validate_number(:display_order, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:product_id)
  end
end
~~~

## Product Association

Update:

~~~text
lib/ca_heo_shop/products/product.ex
~~~

Add association:

~~~elixir
has_many :product_images, CaHeoShop.Products.ProductImage
~~~

Keep this separate from variant image behavior.

Product-level gallery:

~~~text
product_images.filename
~~~

Variant-level representative image:

~~~text
product_variants.image_filename
~~~

## Context Functions

Update:

~~~text
lib/ca_heo_shop/products.ex
~~~

Add aliases:

~~~elixir
alias CaHeoShop.Products.ProductImage
~~~

If needed, import query helpers:

~~~elixir
import Ecto.Query, warn: false
~~~

Add context functions:

~~~elixir
def list_product_images(product) do
  ProductImage
  |> where([image], image.product_id == ^product.id)
  |> order_by([image], asc: image.display_order, asc: image.id)
  |> Repo.all()
end

def list_product_images_without_thumbnail do
  ProductImage
  |> where([image], image.has_thumbnail == false)
  |> order_by([image], asc: image.id)
  |> Repo.all()
end

def get_product_image!(id), do: Repo.get!(ProductImage, id)

def create_product_image(attrs \\ %{}) do
  %ProductImage{}
  |> ProductImage.changeset(attrs)
  |> Repo.insert()
end

def create_product_image_for_product(product, attrs \\ %{}) do
  attrs =
    attrs
    |> Map.new()
    |> Map.put(:product_id, product.id)

  create_product_image(attrs)
end

def update_product_image(%ProductImage{} = product_image, attrs) do
  product_image
  |> ProductImage.changeset(attrs)
  |> Repo.update()
end

def mark_product_image_thumbnail_created(%ProductImage{} = product_image) do
  update_product_image(product_image, %{has_thumbnail: true})
end

def mark_product_image_thumbnail_missing(%ProductImage{} = product_image) do
  update_product_image(product_image, %{has_thumbnail: false})
end

def delete_product_image(%ProductImage{} = product_image) do
  Repo.delete(product_image)
end

def change_product_image(%ProductImage{} = product_image, attrs \\ %{}) do
  ProductImage.changeset(product_image, attrs)
end
~~~

If the project currently avoids `where/3` and `order_by/3`, use `from/2` instead.

Example:

~~~elixir
def list_product_images(product) do
  Repo.all(
    from image in ProductImage,
      where: image.product_id == ^product.id,
      order_by: [asc: image.display_order, asc: image.id]
  )
end
~~~

## Thumbnail Behavior Notes

This task should only prepare the table and context helpers.

Expected future flow:

~~~text
Product image is created
has_thumbnail starts as false
ThumbnailGenerator finds images where has_thumbnail == false
ThumbnailGenerator creates thumbnail file
If thumbnail generation succeeds, has_thumbnail becomes true
If thumbnail generation fails, has_thumbnail remains false
~~~

When creating product images, callers should not need to pass `has_thumbnail`.

Default should be:

~~~elixir
has_thumbnail: false
~~~

When replacing an image filename in a later task, the app should reset:

~~~elixir
has_thumbnail: false
~~~

Reason:

~~~text
A new original image needs a new thumbnail.
~~~

That filename replacement behavior can be implemented in a later image-management task.

## Tests

Add or update tests in:

~~~text
test/ca_heo_shop/products_test.exs
~~~

Test cases:

~~~text
create_product_image/1 creates a product image with valid data
create_product_image/1 defaults has_thumbnail to false
create_product_image/1 can store has_thumbnail as true
create_product_image/1 rejects missing product_id
create_product_image/1 rejects missing filename
create_product_image/1 rejects negative display_order
list_product_images/1 returns only images for the given product
list_product_images/1 orders images by display_order then id
list_product_images_without_thumbnail/0 returns only images where has_thumbnail is false
update_product_image/2 updates filename and display_order
update_product_image/2 can update has_thumbnail
mark_product_image_thumbnail_created/1 sets has_thumbnail to true
mark_product_image_thumbnail_missing/1 sets has_thumbnail to false
delete_product_image/1 deletes the image
~~~

Use existing product fixtures if available.

If no product fixture exists yet, create or extend:

~~~text
test/support/fixtures/products_fixtures.ex
~~~

Possible fixture:

~~~elixir
def product_image_fixture(product, attrs \\ %{}) do
  attrs =
    Enum.into(attrs, %{
      filename: "example-image.jpg",
      display_order: 0
    })

  {:ok, product_image} =
    CaHeoShop.Products.create_product_image_for_product(product, attrs)

  product_image
end
~~~

## Acceptance Criteria

- `mix ecto.migrate` creates the `product_images` table successfully.
- `product_images.product_id` references `products.id`.
- Deleting a product deletes its product images.
- `product_images.filename` is required.
- `product_images.display_order` is required.
- `product_images.display_order` defaults to `0`.
- `product_images.has_thumbnail` exists.
- `product_images.has_thumbnail` is boolean.
- `product_images.has_thumbnail` is not nullable.
- `product_images.has_thumbnail` defaults to `false`.
- `CaHeoShop.Products.ProductImage` exists.
- `CaHeoShop.Products.Product` has many `product_images`.
- `CaHeoShop.Products` exposes product image CRUD helpers.
- Product image listing is scoped by product.
- Product image listing is ordered by `display_order`, then `id`.
- There is a context helper to list images without thumbnails.
- There are context helpers to mark thumbnail state as created or missing.
- Tests pass with:

~~~bash
mix test
~~~

## Notes

Keep this task focused on the database, schema, context, and tests.

Image upload and real thumbnail generation should be handled by later tasks.

Do not create a separate `ProductImages` context unless a future business need makes product images independent from product management.
