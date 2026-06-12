defmodule CaHeoShop.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating catalog entities.
  """

  alias CaHeoShop.Catalog

  def unique_collection_slug, do: "collection-#{System.unique_integer([:positive])}"

  def valid_collection_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name_vi: "Bo suu tap",
      name_en: "Collection",
      slug: unique_collection_slug(),
      description_vi: "Mo ta tieng Viet",
      description_en: "English description",
      image_filename: "/images/storefront/category-prints.svg",
      nav_display_order: 0
    })
  end

  def collection_fixture(attrs \\ %{}) do
    {:ok, collection} =
      attrs
      |> valid_collection_attributes()
      |> Catalog.create_collection()

    collection
  end
end
