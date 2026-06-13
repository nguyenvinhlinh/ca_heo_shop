defmodule CaHeoShop.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias CaHeoShop.Repo

  alias CaHeoShop.Collections.Collection
  alias CaHeoShop.Products.Product
  alias CaHeoShop.Products.ProductImage
  alias CaHeoShop.Products.ProductVariant

  def list_products do
    Repo.all(Product)
  end

  def list_products_by_collection(%Collection{id: collection_id}) do
    list_products_by_collection(collection_id)
  end

  def list_products_by_collection(collection_id) do
    Product
    |> where([p], p.collection_id == ^collection_id)
    |> order_by([p], asc: p.name_vi)
    |> Repo.all()
  end

  def list_uncategorized_products do
    Product
    |> where([p], is_nil(p.collection_id))
    |> order_by([p], asc: p.name_vi)
    |> Repo.all()
  end

  def list_product_images(%Product{id: product_id}) do
    list_product_images(product_id)
  end

  def list_product_images(product_id) do
    ProductImage
    |> where([image], image.product_id == ^product_id)
    |> order_by([image], asc: image.display_order, asc: image.id)
    |> Repo.all()
  end

  def list_product_images_without_thumbnail do
    ProductImage
    |> where([image], image.has_thumbnail == false)
    |> order_by([image], asc: image.id)
    |> Repo.all()
  end

  def list_product_variants(%Product{id: product_id}) do
    list_product_variants(product_id)
  end

  def list_product_variants(product_id) do
    ProductVariant
    |> where([variant], variant.product_id == ^product_id)
    |> order_by([variant], asc: variant.display_order, asc: variant.inserted_at)
    |> Repo.all()
  end

  def get_product!(id), do: Repo.get!(Product, id)
  def get_product_image!(id), do: Repo.get!(ProductImage, id)
  def get_product_variant!(id), do: Repo.get!(ProductVariant, id)

  def get_product_by_slug!(slug) when is_binary(slug) do
    Repo.get_by!(Product, slug: slug)
  end

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def create_product_image(attrs \\ %{}) do
    %ProductImage{}
    |> ProductImage.changeset(attrs)
    |> Repo.insert()
  end

  def create_product_variant(attrs \\ %{}) do
    %ProductVariant{}
    |> ProductVariant.changeset(attrs)
    |> Repo.insert()
  end

  def create_product_image_for_product(%Product{id: product_id}, attrs \\ %{}) do
    attrs =
      attrs
      |> Map.new()
      |> Map.put(:product_id, product_id)

    create_product_image(attrs)
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def update_product_image(%ProductImage{} = product_image, attrs) do
    product_image
    |> ProductImage.changeset(attrs)
    |> Repo.update()
  end

  def update_product_variant(%ProductVariant{} = product_variant, attrs) do
    product_variant
    |> ProductVariant.changeset(attrs)
    |> Repo.update()
  end

  def mark_product_image_thumbnail_created(%ProductImage{} = product_image) do
    update_product_image(product_image, %{has_thumbnail: true})
  end

  def mark_product_image_thumbnail_missing(%ProductImage{} = product_image) do
    update_product_image(product_image, %{has_thumbnail: false})
  end

  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  def delete_product_image(%ProductImage{} = product_image) do
    Repo.delete(product_image)
  end

  def delete_product_variant(%ProductVariant{} = product_variant) do
    Repo.delete(product_variant)
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  def change_product_image(%ProductImage{} = product_image, attrs \\ %{}) do
    ProductImage.changeset(product_image, attrs)
  end

  def change_product_variant(%ProductVariant{} = product_variant, attrs \\ %{}) do
    ProductVariant.changeset(product_variant, attrs)
  end
end
