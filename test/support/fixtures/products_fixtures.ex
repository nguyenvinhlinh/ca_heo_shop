defmodule CaHeoShop.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating products.
  """

  alias CaHeoShop.Products

  import CaHeoShop.CatalogFixtures

  def unique_product_slug, do: "product-#{System.unique_integer([:positive])}"

  def valid_product_attributes(attrs \\ %{}) do
    attrs = Map.new(attrs)
    collection = Map.get_lazy(attrs, :collection, fn -> collection_fixture() end)

    attrs
    |> Map.delete(:collection)
    |> Enum.into(%{
      collection_id: collection.id,
      slug: unique_product_slug(),
      name_vi: "San pham",
      name_en: "Product",
      description_vi: "Mo ta san pham",
      description_en: "Product description"
    })
  end

  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> valid_product_attributes()
      |> Products.create_product()

    product
  end
end
