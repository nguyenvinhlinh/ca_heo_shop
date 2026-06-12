defmodule CaHeoShop.ProductsTest do
  use CaHeoShop.DataCase

  alias CaHeoShop.Products
  alias CaHeoShop.Products.Product

  import CaHeoShop.CatalogFixtures
  import CaHeoShop.ProductsFixtures

  describe "products" do
    test "change_product/2 requires collection_id, slug, name_vi, and name_en" do
      changeset = Products.change_product(%Product{}, %{})

      assert %{
               collection_id: ["can't be blank"],
               slug: ["can't be blank"],
               name_vi: ["can't be blank"],
               name_en: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "create_product/1 enforces unique slug" do
      product = product_fixture()

      assert {:error, changeset} =
               Products.create_product(valid_product_attributes(slug: product.slug))

      assert "has already been taken" in errors_on(changeset).slug
    end

    test "create_product/1 enforces collection foreign key" do
      assert {:error, changeset} =
               Products.create_product(valid_product_attributes(collection_id: -1))

      assert "does not exist" in errors_on(changeset).collection_id
    end

    test "list_products_by_collection/1 returns only products for the collection" do
      collection = collection_fixture()
      other_collection = collection_fixture()
      product = product_fixture(collection: collection)
      _other_product = product_fixture(collection: other_collection)

      assert Products.list_products_by_collection(collection) == [product]
    end

    test "creates, updates, and deletes products" do
      collection = collection_fixture()

      assert {:ok, product} =
               Products.create_product(
                 valid_product_attributes(collection: collection, name_vi: "Original")
               )

      assert {:ok, product} = Products.update_product(product, %{name_vi: "Updated"})
      assert product.name_vi == "Updated"
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end
  end
end
