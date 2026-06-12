defmodule CaHeoShop.ProductVariantsTest do
  use CaHeoShop.DataCase

  alias CaHeoShop.ProductVariants
  alias CaHeoShop.ProductVariants.ProductVariant

  import CaHeoShop.ProductVariantsFixtures
  import CaHeoShop.ProductsFixtures

  describe "product_variants" do
    test "change_product_variant/2 requires required fields" do
      changeset = ProductVariants.change_product_variant(%ProductVariant{}, %{})

      assert %{
               product_id: ["can't be blank"],
               variant_name: ["can't be blank"],
               production_cost: ["can't be blank"],
               selling_price: ["can't be blank"],
               stock_quantity: ["can't be blank"],
               display_order: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "create_product_variant/1 enforces unique product and variant_name" do
      product = product_fixture()
      product_variant_fixture(product: product, variant_name: "Black")

      assert {:error, changeset} =
               ProductVariants.create_product_variant(
                 valid_product_variant_attributes(product: product, variant_name: "Black")
               )

      assert "has already been taken" in errors_on(changeset).variant_name
    end

    test "create_product_variant/1 enforces product foreign key" do
      assert {:error, changeset} =
               ProductVariants.create_product_variant(
                 valid_product_variant_attributes(product_id: -1)
               )

      assert "does not exist" in errors_on(changeset).product_id
    end

    test "change_product_variant/2 validates non-negative integer fields" do
      changeset =
        ProductVariants.change_product_variant(%ProductVariant{}, %{
          product_id: 1,
          variant_name: "Black",
          production_cost: -1,
          selling_price: -1,
          stock_quantity: -1,
          display_order: -1
        })

      assert "must be greater than or equal to 0" in errors_on(changeset).production_cost
      assert "must be greater than or equal to 0" in errors_on(changeset).selling_price
      assert "must be greater than or equal to 0" in errors_on(changeset).stock_quantity
      assert "must be greater than or equal to 0" in errors_on(changeset).display_order
    end

    test "list_product_variants_for_product/1 orders by display_order then id" do
      product = product_fixture()
      second = product_variant_fixture(product: product, variant_name: "Second", display_order: 1)
      first = product_variant_fixture(product: product, variant_name: "First", display_order: 0)

      assert ProductVariants.list_product_variants_for_product(product) == [first, second]
    end

    test "creates, updates, and deletes product variants" do
      product = product_fixture()

      assert {:ok, product_variant} =
               ProductVariants.create_product_variant(
                 valid_product_variant_attributes(product: product, variant_name: "Original")
               )

      assert {:ok, product_variant} =
               ProductVariants.update_product_variant(product_variant, %{variant_name: "Updated"})

      assert product_variant.variant_name == "Updated"
      assert {:ok, %ProductVariant{}} = ProductVariants.delete_product_variant(product_variant)

      assert_raise Ecto.NoResultsError, fn ->
        ProductVariants.get_product_variant!(product_variant.id)
      end
    end
  end
end
