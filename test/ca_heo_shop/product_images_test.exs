defmodule CaHeoShop.ProductImagesTest do
  use CaHeoShop.DataCase

  alias CaHeoShop.ProductImages
  alias CaHeoShop.ProductImages.ProductImage

  import CaHeoShop.ProductImagesFixtures
  import CaHeoShop.ProductsFixtures

  describe "product_images" do
    test "change_product_image/2 requires product_id, filename, and display_order" do
      changeset = ProductImages.change_product_image(%ProductImage{}, %{})

      assert %{
               product_id: ["can't be blank"],
               filename: ["can't be blank"],
               display_order: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "change_product_image/2 validates non-negative display_order" do
      changeset =
        ProductImages.change_product_image(%ProductImage{}, %{
          product_id: 1,
          filename: "image.svg",
          display_order: -1
        })

      assert "must be greater than or equal to 0" in errors_on(changeset).display_order
    end

    test "create_product_image/1 enforces product foreign key" do
      assert {:error, changeset} =
               ProductImages.create_product_image(%{
                 product_id: -1,
                 filename: "image.svg",
                 display_order: 0
               })

      assert "does not exist" in errors_on(changeset).product_id
    end

    test "list_product_images_for_product/1 orders by display_order then id" do
      product = product_fixture()
      second = product_image_fixture(product: product, filename: "b.svg", display_order: 1)
      first = product_image_fixture(product: product, filename: "a.svg", display_order: 0)

      assert ProductImages.list_product_images_for_product(product) == [first, second]
    end

    test "creates, updates, and deletes product images" do
      product = product_fixture()

      assert {:ok, product_image} =
               ProductImages.create_product_image(%{
                 product_id: product.id,
                 filename: "original.svg",
                 display_order: 0
               })

      assert {:ok, product_image} =
               ProductImages.update_product_image(product_image, %{filename: "updated.svg"})

      assert product_image.filename == "updated.svg"
      assert {:ok, %ProductImage{}} = ProductImages.delete_product_image(product_image)

      assert_raise Ecto.NoResultsError, fn ->
        ProductImages.get_product_image!(product_image.id)
      end
    end
  end
end
