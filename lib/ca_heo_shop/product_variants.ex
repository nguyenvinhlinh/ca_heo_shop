defmodule CaHeoShop.ProductVariants do
  @moduledoc """
  The ProductVariants context.
  """

  import Ecto.Query, warn: false
  alias CaHeoShop.Repo

  alias CaHeoShop.ProductVariants.ProductVariant
  alias CaHeoShop.Products.Product

  def list_product_variants do
    Repo.all(ProductVariant)
  end

  def list_product_variants_for_product(%Product{id: product_id}) do
    list_product_variants_for_product(product_id)
  end

  def list_product_variants_for_product(product_id) do
    ProductVariant
    |> where([variant], variant.product_id == ^product_id)
    |> order_by([variant], asc: variant.display_order, asc: variant.id)
    |> Repo.all()
  end

  def get_product_variant!(id), do: Repo.get!(ProductVariant, id)

  def create_product_variant(attrs \\ %{}) do
    %ProductVariant{}
    |> ProductVariant.changeset(attrs)
    |> Repo.insert()
  end

  def update_product_variant(%ProductVariant{} = product_variant, attrs) do
    product_variant
    |> ProductVariant.changeset(attrs)
    |> Repo.update()
  end

  def delete_product_variant(%ProductVariant{} = product_variant) do
    Repo.delete(product_variant)
  end

  def change_product_variant(%ProductVariant{} = product_variant, attrs \\ %{}) do
    ProductVariant.changeset(product_variant, attrs)
  end
end
