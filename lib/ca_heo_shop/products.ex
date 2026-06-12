defmodule CaHeoShop.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias CaHeoShop.Repo

  alias CaHeoShop.Catalog.Collection
  alias CaHeoShop.Products.Product

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

  def get_product!(id), do: Repo.get!(Product, id)

  def get_product_by_slug!(slug) when is_binary(slug) do
    Repo.get_by!(Product, slug: slug)
  end

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end
