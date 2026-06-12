defmodule CaHeoShop.ProductImagesFixtures do
  @moduledoc """
  This module defines test helpers for creating product images.
  """

  alias CaHeoShop.ProductImages

  import CaHeoShop.ProductsFixtures

  def valid_product_image_attributes(attrs \\ %{}) do
    attrs = Map.new(attrs)
    product = Map.get_lazy(attrs, :product, fn -> product_fixture() end)

    attrs
    |> Map.delete(:product)
    |> Enum.into(%{
      product_id: product.id,
      filename: "/images/storefront/product-organizer.svg",
      display_order: 0
    })
  end

  def product_image_fixture(attrs \\ %{}) do
    {:ok, product_image} =
      attrs
      |> valid_product_image_attributes()
      |> ProductImages.create_product_image()

    product_image
  end
end
