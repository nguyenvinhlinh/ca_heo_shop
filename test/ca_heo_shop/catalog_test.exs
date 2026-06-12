defmodule CaHeoShop.CatalogTest do
  use CaHeoShop.DataCase

  alias CaHeoShop.Catalog
  alias CaHeoShop.Catalog.Collection

  import CaHeoShop.CatalogFixtures

  describe "collections" do
    test "change_collection/2 requires name_vi, name_en, and slug" do
      changeset = Catalog.change_collection(%Collection{}, %{})

      assert %{name_vi: ["can't be blank"], name_en: ["can't be blank"], slug: ["can't be blank"]} =
               errors_on(changeset)
    end

    test "create_collection/1 enforces unique slug" do
      collection = collection_fixture()

      assert {:error, changeset} =
               Catalog.create_collection(valid_collection_attributes(slug: collection.slug))

      assert "has already been taken" in errors_on(changeset).slug
    end

    test "change_collection/2 validates non-negative nav_display_order" do
      changeset =
        Catalog.change_collection(
          %Collection{},
          valid_collection_attributes(nav_display_order: -1)
        )

      assert "must be greater than or equal to 0" in errors_on(changeset).nav_display_order
    end

    test "list_nav_collections/0 filters null nav rows and orders from zero upward" do
      hidden = collection_fixture(nav_display_order: nil, name_vi: "Hidden")
      second = collection_fixture(nav_display_order: 1, name_vi: "Second")
      first = collection_fixture(nav_display_order: 0, name_vi: "First")

      nav_collections = Catalog.list_nav_collections()

      assert Enum.map(nav_collections, & &1.id) == [first.id, second.id]
      refute hidden.id in Enum.map(nav_collections, & &1.id)
    end
  end
end
