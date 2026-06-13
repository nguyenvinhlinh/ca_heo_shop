defmodule CaHeoShop.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating products.
  """

  alias CaHeoShop.Products

  import CaHeoShop.CollectionsFixtures

  def unique_product_slug, do: "product-#{System.unique_integer([:positive])}"

  def valid_product_attributes(attrs \\ %{}) do
    attrs = Map.new(attrs)

    collection =
      cond do
        Map.has_key?(attrs, :collection_id) ->
          nil

        Map.has_key?(attrs, :collection) ->
          Map.fetch!(attrs, :collection)

        true ->
          collection_fixture()
      end

    attrs
    |> Map.delete(:collection)
    |> Enum.into(%{
      collection_id: collection && collection.id,
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

  def valid_product_image_attributes(product, attrs \\ %{}) do
    attrs
    |> Map.new()
    |> Enum.into(%{
      product_id: product.id,
      filename: "/images/storefront/product-organizer.svg",
      display_order: 0,
      has_thumbnail: false
    })
  end

  def product_image_fixture(product, attrs \\ %{}) do
    {:ok, product_image} =
      product
      |> valid_product_image_attributes(attrs)
      |> Products.create_product_image()

    product_image
  end

  def valid_product_variant_attributes(product, attrs \\ %{}) do
    attrs
    |> Map.new()
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

  def product_variant_fixture(product, attrs \\ %{}) do
    {:ok, product_variant} =
      product
      |> valid_product_variant_attributes(attrs)
      |> Products.create_product_variant()

    product_variant
  end
end
