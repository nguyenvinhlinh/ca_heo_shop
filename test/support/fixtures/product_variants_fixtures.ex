defmodule CaHeoShop.ProductVariantsFixtures do
  @moduledoc """
  This module defines test helpers for creating product variants.
  """

  alias CaHeoShop.ProductVariants

  import CaHeoShop.ProductsFixtures

  def valid_product_variant_attributes(attrs \\ %{}) do
    attrs = Map.new(attrs)
    product = Map.get_lazy(attrs, :product, fn -> product_fixture() end)

    attrs
    |> Map.delete(:product)
    |> Enum.into(%{
      product_id: product.id,
      variant_name: "Matte black PLA",
      production_cost: 45_000,
      selling_price: 120_000,
      stock_quantity: 8,
      image_filename: "/images/storefront/product-organizer.svg",
      display_order: 0
    })
  end

  def product_variant_fixture(attrs \\ %{}) do
    {:ok, product_variant} =
      attrs
      |> valid_product_variant_attributes()
      |> ProductVariants.create_product_variant()

    product_variant
  end
end
