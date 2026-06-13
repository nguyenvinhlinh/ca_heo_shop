defmodule CaHeoShop.ProductsTest do
  use CaHeoShop.DataCase

  alias CaHeoShop.Products
  alias CaHeoShop.Products.Product
  alias CaHeoShop.Products.ProductImage
  alias CaHeoShop.Products.ProductVariant

  import CaHeoShop.CollectionsFixtures
  import CaHeoShop.ProductsFixtures

  describe "products" do
    test "change_product/2 requires slug, name_vi, and name_en only" do
      changeset = Products.change_product(%Product{}, %{})

      assert %{
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

    test "create_product/1 can create a product with a collection" do
      collection = collection_fixture()

      assert {:ok, product} =
               Products.create_product(valid_product_attributes(collection: collection))

      assert product.collection_id == collection.id
    end

    test "create_product/1 can create a product without a collection" do
      assert {:ok, product} =
               Products.create_product(valid_product_attributes(collection_id: nil))

      assert product.collection_id == nil
    end

    test "list_products_by_collection/1 returns only products for the collection" do
      collection = collection_fixture()
      other_collection = collection_fixture()
      product = product_fixture(collection: collection)
      _other_product = product_fixture(collection: other_collection)

      assert Products.list_products_by_collection(collection) == [product]
    end

    test "list_uncategorized_products/0 returns only products without a collection" do
      uncategorized = product_fixture(collection_id: nil, name_vi: "No Collection")
      _categorized = product_fixture(name_vi: "With Collection")

      assert Products.list_uncategorized_products() == [uncategorized]
    end

    test "creates, updates, and deletes products" do
      assert {:ok, product} =
               Products.create_product(
                 valid_product_attributes(collection_id: nil, name_vi: "Original")
               )

      assert {:ok, product} = Products.update_product(product, %{name_vi: "Updated"})
      assert product.name_vi == "Updated"
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end
  end

  describe "admin product listing" do
    test "returns paginated products with collection, image, and variant preloads" do
      collection =
        collection_fixture(name_vi: "Bo suu tap A", name_en: "Collection A", nav_display_order: 0)

      older = product_fixture(collection: collection, slug: "older-product", name_vi: "Cu")
      newer = product_fixture(collection: nil, slug: "newer-product", name_vi: "Moi")

      later_image =
        product_image_fixture(newer, %{
          filename: "later.jpg",
          display_order: 2,
          has_thumbnail: false
        })

      first_image =
        product_image_fixture(newer, %{
          filename: "first.jpg",
          display_order: 0,
          has_thumbnail: true
        })

      later_variant =
        product_variant_fixture(newer, %{
          variant_name: "Variant later",
          display_order: 2,
          selling_price: 90_000
        })

      first_variant =
        product_variant_fixture(newer, %{
          variant_name: "Variant first",
          display_order: 0,
          selling_price: 100_000
        })

      page = Products.list_admin_products(%{"page" => "1", "per_page" => "20"})

      assert page.page == 1
      assert page.per_page == 20
      assert page.total_count == 2
      assert page.total_pages == 1
      assert page.from == 1
      assert page.to == 2
      assert Enum.map(page.entries, & &1.id) == [newer.id, older.id]

      product = hd(page.entries)

      assert Ecto.assoc_loaded?(product.collection)
      assert Ecto.assoc_loaded?(product.product_images)
      assert Ecto.assoc_loaded?(product.product_variants)
      assert Enum.map(product.product_images, & &1.id) == [first_image.id, later_image.id]
      assert Enum.map(product.product_variants, & &1.id) == [first_variant.id, later_variant.id]
    end

    test "returns second page and supports per_page normalization" do
      for index <- 1..25 do
        product_fixture(slug: "page-product-#{index}", name_vi: "San pham #{index}")
      end

      first_page = Products.list_admin_products(%{"page" => "1", "per_page" => "20"})
      second_page = Products.list_admin_products(%{"page" => "2", "per_page" => "20"})
      normalized = Products.list_admin_products(%{"page" => "-9", "per_page" => "999"})

      assert length(first_page.entries) == 20
      assert first_page.from == 1
      assert first_page.to == 20
      assert second_page.page == 2
      assert length(second_page.entries) == 5
      assert second_page.from == 21
      assert second_page.to == 25
      assert normalized.page == 1
      assert normalized.per_page == 20
    end

    test "returns 0-0 range when there are no products" do
      page = Products.list_admin_products()

      assert page.entries == []
      assert page.total_count == 0
      assert page.from == 0
      assert page.to == 0
    end

    test "filters products by collection all null and concrete id" do
      collection = collection_fixture(name_vi: "Co bo suu tap")
      other_collection = collection_fixture(name_vi: "Bo suu tap khac")
      in_collection = product_fixture(collection: collection, slug: "in-collection")
      other = product_fixture(collection: other_collection, slug: "other-collection")
      uncategorized = product_fixture(collection_id: nil, slug: "no-collection")

      all_products = Products.list_admin_products(%{"collection" => "ALL"})
      null_products = Products.list_admin_products(%{"collection" => "NULL"})

      selected_products =
        Products.list_admin_products(%{"collection" => Integer.to_string(collection.id)})

      invalid_products = Products.list_admin_products(%{"collection" => "invalid"})

      assert Enum.map(all_products.entries, & &1.id) |> Enum.sort() ==
               Enum.sort([in_collection.id, other.id, uncategorized.id])

      assert Enum.map(null_products.entries, & &1.id) == [uncategorized.id]
      assert Enum.map(selected_products.entries, & &1.id) == [in_collection.id]

      assert Enum.map(invalid_products.entries, & &1.id) |> Enum.sort() ==
               Enum.map(all_products.entries, & &1.id) |> Enum.sort()
    end

    test "searches by vietnamese and english name and combines with collection filter" do
      collection = collection_fixture(name_vi: "Dung cu")

      vi_product =
        product_fixture(
          collection: collection,
          slug: "gia-do",
          name_vi: "Gia do ban phim",
          name_en: "Keyboard Stand"
        )

      en_product =
        product_fixture(
          collection_id: nil,
          slug: "peg-board",
          name_vi: "Bang treo",
          name_en: "Peg Board"
        )

      _other =
        product_fixture(
          collection: collection,
          slug: "cable-box",
          name_vi: "Hop day cap",
          name_en: "Cable Box"
        )

      vi_search = Products.list_admin_products(%{"q" => "  gia do  "})
      en_search = Products.list_admin_products(%{"q" => "peg board"})
      case_insensitive = Products.list_admin_products(%{"q" => "KEYBOARD"})

      combined =
        Products.list_admin_products(%{
          "collection" => Integer.to_string(collection.id),
          "q" => "keyboard"
        })

      blank_search = Products.list_admin_products(%{"q" => "   "})

      assert Enum.map(vi_search.entries, & &1.id) == [vi_product.id]
      assert Enum.map(en_search.entries, & &1.id) == [en_product.id]
      assert Enum.map(case_insensitive.entries, & &1.id) == [vi_product.id]
      assert Enum.map(combined.entries, & &1.id) == [vi_product.id]
      assert blank_search.total_count == 3
    end
  end

  describe "product images" do
    test "change_product_image/2 requires product_id and filename" do
      changeset = Products.change_product_image(%ProductImage{}, %{})

      assert %{
               product_id: ["can't be blank"],
               filename: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "create_product_image/1 creates a product image and defaults has_thumbnail to false" do
      product = product_fixture()

      assert {:ok, product_image} =
               Products.create_product_image(%{
                 product_id: product.id,
                 filename: "example-image.jpg",
                 display_order: 0
               })

      assert product_image.has_thumbnail == false
    end

    test "create_product_image/1 can store has_thumbnail as true" do
      product = product_fixture()

      assert {:ok, product_image} =
               Products.create_product_image(%{
                 product_id: product.id,
                 filename: "done-image.jpg",
                 display_order: 0,
                 has_thumbnail: true
               })

      assert product_image.has_thumbnail == true
    end

    test "create_product_image/1 enforces product foreign key" do
      assert {:error, changeset} =
               Products.create_product_image(%{
                 product_id: -1,
                 filename: "image.svg",
                 display_order: 0,
                 has_thumbnail: false
               })

      assert "does not exist" in errors_on(changeset).product_id
    end

    test "create_product_image/1 rejects negative display_order" do
      changeset =
        Products.change_product_image(%ProductImage{}, %{
          product_id: 1,
          filename: "image.svg",
          display_order: -1,
          has_thumbnail: false
        })

      assert "must be greater than or equal to 0" in errors_on(changeset).display_order
    end

    test "list_product_images/1 returns only images for the given product ordered by display_order then id" do
      product = product_fixture()
      other_product = product_fixture()
      second = product_image_fixture(product, %{filename: "b.svg", display_order: 1})
      first = product_image_fixture(product, %{filename: "a.svg", display_order: 0})
      _other = product_image_fixture(other_product, %{filename: "c.svg", display_order: 0})

      assert Products.list_product_images(product) == [first, second]
    end

    test "list_product_images_without_thumbnail/0 returns only images without thumbnails" do
      product = product_fixture()
      missing = product_image_fixture(product, %{filename: "missing.jpg", has_thumbnail: false})
      _created = product_image_fixture(product, %{filename: "created.jpg", has_thumbnail: true})

      assert Products.list_product_images_without_thumbnail() == [missing]
    end

    test "create_product_image_for_product/2 injects the product id" do
      product = product_fixture()

      assert {:ok, product_image} =
               Products.create_product_image_for_product(product, %{
                 filename: "created-via-helper.jpg"
               })

      assert product_image.product_id == product.id
      assert product_image.display_order == 0
      assert product_image.has_thumbnail == false
    end

    test "update_product_image/2 updates filename, display_order, and has_thumbnail" do
      product = product_fixture()
      product_image = product_image_fixture(product)

      assert {:ok, updated_product_image} =
               Products.update_product_image(product_image, %{
                 filename: "updated.svg",
                 display_order: 2,
                 has_thumbnail: true
               })

      assert updated_product_image.filename == "updated.svg"
      assert updated_product_image.display_order == 2
      assert updated_product_image.has_thumbnail == true
    end

    test "mark_product_image_thumbnail_created/1 sets has_thumbnail to true" do
      product = product_fixture()
      product_image = product_image_fixture(product, %{has_thumbnail: false})

      assert {:ok, updated_product_image} =
               Products.mark_product_image_thumbnail_created(product_image)

      assert updated_product_image.has_thumbnail == true
    end

    test "mark_product_image_thumbnail_missing/1 sets has_thumbnail to false" do
      product = product_fixture()
      product_image = product_image_fixture(product, %{has_thumbnail: true})

      assert {:ok, updated_product_image} =
               Products.mark_product_image_thumbnail_missing(product_image)

      assert updated_product_image.has_thumbnail == false
    end

    test "delete_product_image/1 deletes the image" do
      product = product_fixture()
      product_image = product_image_fixture(product)

      assert {:ok, %ProductImage{}} = Products.delete_product_image(product_image)

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product_image!(product_image.id)
      end
    end

    test "deleting a product deletes its product images" do
      product = product_fixture()
      product_image = product_image_fixture(product)

      assert {:ok, %Product{}} = Products.delete_product(product)

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product_image!(product_image.id)
      end
    end
  end

  describe "product variants" do
    test "create_product_variant/1 requires product_id, variant_name, and selling_price" do
      changeset = Products.change_product_variant(%ProductVariant{}, %{})

      assert %{
               product_id: ["can't be blank"],
               variant_name: ["can't be blank"],
               selling_price: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "create_product_variant/1 creates a valid variant" do
      product = product_fixture()

      assert {:ok, product_variant} =
               Products.create_product_variant(%{
                 product_id: product.id,
                 variant_name: "PLA Red",
                 production_cost: 10_000,
                 selling_price: 50_000,
                 stock_quantity: 5,
                 image_filename: "pla-red.jpg",
                 display_order: 0
               })

      assert product_variant.variant_name == "PLA Red"
    end

    test "create_product_variant/1 enforces unique variant_name per product" do
      product = product_fixture()
      product_variant_fixture(product, %{variant_name: "Black"})

      assert {:error, changeset} =
               Products.create_product_variant(
                 valid_product_variant_attributes(product, %{variant_name: "Black"})
               )

      assert "has already been taken" in errors_on(changeset).variant_name
    end

    test "create_product_variant/1 enforces product foreign key" do
      assert {:error, changeset} =
               Products.create_product_variant(
                 valid_product_variant_attributes(product_fixture(), %{product_id: -1})
               )

      assert "does not exist" in errors_on(changeset).product_id
    end

    test "create_product_variant/1 rejects negative numeric fields" do
      changeset =
        Products.change_product_variant(%ProductVariant{}, %{
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

    test "list_product_variants/1 returns only variants for the given product ordered by display_order then inserted_at" do
      product = product_fixture()
      other_product = product_fixture()
      second = product_variant_fixture(product, %{variant_name: "Second", display_order: 1})
      first = product_variant_fixture(product, %{variant_name: "First", display_order: 0})
      _other = product_variant_fixture(other_product, %{variant_name: "Other", display_order: 0})

      assert Products.list_product_variants(product) == [first, second]
    end

    test "update_product_variant/2 updates editable fields" do
      product = product_fixture()
      product_variant = product_variant_fixture(product, %{variant_name: "Original"})

      assert {:ok, updated_product_variant} =
               Products.update_product_variant(product_variant, %{
                 variant_name: "Updated",
                 selling_price: 55_000,
                 display_order: 1
               })

      assert updated_product_variant.variant_name == "Updated"
      assert updated_product_variant.selling_price == 55_000
      assert updated_product_variant.display_order == 1
    end

    test "delete_product_variant/1 deletes the variant" do
      product = product_fixture()
      product_variant = product_variant_fixture(product)

      assert {:ok, %ProductVariant{}} = Products.delete_product_variant(product_variant)

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product_variant!(product_variant.id)
      end
    end

    test "change_product_variant/1 returns a changeset" do
      product = product_fixture()
      product_variant = product_variant_fixture(product)

      assert %Ecto.Changeset{} = Products.change_product_variant(product_variant)
    end

    test "deleting a product deletes its variants" do
      product = product_fixture()
      product_variant = product_variant_fixture(product)

      assert {:ok, %Product{}} = Products.delete_product(product)

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product_variant!(product_variant.id)
      end
    end
  end
end
