defmodule CaHeoShop.ProductsTest do
  use CaHeoShop.DataCase

  alias CaHeoShop.Products
  alias CaHeoShop.Products.Product
  alias CaHeoShop.Products.ProductImage
  alias CaHeoShop.Products.ProductVariant
  alias CaHeoShop.Repo
  alias CaHeoShop.Uploads

  import CaHeoShop.CollectionsFixtures
  import CaHeoShop.ProductsFixtures

  setup :set_product_assets_path

  describe "products" do
    test "create_product/1 validates slug format and length" do
      assert {:ok, _product} =
               Products.create_product(
                 valid_product_attributes(slug: "pla-red-phone-holder", collection_id: nil)
               )

      for invalid_slug <- [
            "Universal Phone Stand",
            "universal_phone_stand",
            "universal phone stand",
            "universal--phone-stand",
            "Universal-phone-stand"
          ] do
        assert {:error, changeset} =
                 Products.create_product(
                   valid_product_attributes(slug: invalid_slug, collection_id: nil)
                 )

        assert "has invalid format" in errors_on(changeset).slug
      end

      long_slug = String.duplicate("a", 161)

      assert {:error, changeset} =
               Products.create_product(
                 valid_product_attributes(slug: long_slug, collection_id: nil)
               )

      assert "should be at most 160 character(s)" in errors_on(changeset).slug
    end

    test "create_product/1 validates product name lengths" do
      long_name = String.duplicate("a", 256)

      assert {:error, changeset} =
               Products.create_product(
                 valid_product_attributes(
                   collection_id: nil,
                   name_vi: long_name,
                   name_en: long_name
                 )
               )

      assert "should be at most 255 character(s)" in errors_on(changeset).name_vi
      assert "should be at most 255 character(s)" in errors_on(changeset).name_en
    end

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

    test "update_product_summary/2 updates only summary fields and allows nil collection_id" do
      collection = collection_fixture(name_vi: "Bo suu tap cu")

      product =
        product_fixture(
          collection: collection,
          slug: "original-slug",
          name_vi: "Ten cu",
          name_en: "Old name",
          description_vi: "Mo ta cu",
          description_en: "Old description"
        )

      assert {:ok, updated_product} =
               Products.update_product_summary(product, %{
                 collection_id: nil,
                 slug: "updated-slug",
                 name_vi: "Ten moi",
                 name_en: "New name",
                 description_vi: "Bi bo qua",
                 description_en: "Ignored"
               })

      assert updated_product.collection_id == nil
      assert updated_product.slug == "updated-slug"
      assert updated_product.name_vi == "Ten moi"
      assert updated_product.name_en == "New name"
      assert updated_product.description_vi == "Mo ta cu"
      assert updated_product.description_en == "Old description"
    end

    test "update_product_summary/2 rejects invalid summary fields" do
      product = product_fixture(slug: "valid-slug")
      other_product = product_fixture(slug: "taken-slug")

      assert {:error, changeset} =
               Products.update_product_summary(product, %{
                 slug: "another-valid-slug",
                 name_vi: "",
                 name_en: ""
               })

      assert "can't be blank" in errors_on(changeset).name_vi
      assert "can't be blank" in errors_on(changeset).name_en

      assert {:error, changeset} =
               Products.update_product_summary(product, %{
                 slug: other_product.slug,
                 name_vi: "Ten hop le",
                 name_en: "Valid name"
               })

      assert "has already been taken" in errors_on(changeset).slug

      assert {:error, changeset} =
               Products.update_product_summary(product, %{
                 collection_id: -1,
                 slug: "valid-slug-2",
                 name_vi: "Ten hop le",
                 name_en: "Valid name"
               })

      assert "does not exist" in errors_on(changeset).collection_id

      assert {:error, changeset} =
               Products.update_product_summary(product, %{
                 slug: "invalid slug",
                 name_vi: "A",
                 name_en: "B"
               })

      assert "has invalid format" in errors_on(changeset).slug
    end

    test "update_product_content/2 updates only content fields" do
      product =
        product_fixture(
          slug: "content-only",
          name_vi: "Ten goc",
          name_en: "Original name",
          description_vi: "Mo ta cu",
          description_en: "Old description"
        )

      assert {:ok, updated_product} =
               Products.update_product_content(product, %{
                 description_vi: "Mo ta moi",
                 description_en: "New description",
                 slug: "ignored-slug",
                 name_vi: "Ignored name",
                 name_en: "Ignored EN"
               })

      assert updated_product.description_vi == "Mo ta moi"
      assert updated_product.description_en == "New description"
      assert updated_product.slug == "content-only"
      assert updated_product.name_vi == "Ten goc"
      assert updated_product.name_en == "Original name"
    end

    test "update_product_content/2 allows clearing descriptions and validates length" do
      product =
        product_fixture(
          description_vi: "Mo ta cu",
          description_en: "Old description"
        )

      assert {:ok, updated_product} =
               Products.update_product_content(product, %{
                 description_vi: "",
                 description_en: nil
               })

      assert updated_product.description_vi == nil
      assert updated_product.description_en == nil

      long_text = String.duplicate("a", 10_001)

      assert {:error, changeset} =
               Products.update_product_content(product, %{
                 description_vi: long_text,
                 description_en: long_text
               })

      assert "should be at most 10000 character(s)" in errors_on(changeset).description_vi
      assert "should be at most 10000 character(s)" in errors_on(changeset).description_en
    end

    test "reorder_product_images/2 updates display_order sequentially and accepts string ids" do
      product = product_fixture()

      first_image = product_image_fixture(product, %{filename: "first.jpg", display_order: 0})
      second_image = product_image_fixture(product, %{filename: "second.jpg", display_order: 1})
      third_image = product_image_fixture(product, %{filename: "third.jpg", display_order: 2})

      assert {:ok, reordered_images} =
               Products.reorder_product_images(product.id, [
                 Integer.to_string(third_image.id),
                 Integer.to_string(first_image.id),
                 Integer.to_string(second_image.id)
               ])

      assert Enum.map(reordered_images, &{&1.id, &1.display_order}) == [
               {third_image.id, 0},
               {first_image.id, 1},
               {second_image.id, 2}
             ]

      assert Enum.map(Products.list_product_images(product), &{&1.id, &1.display_order}) == [
               {third_image.id, 0},
               {first_image.id, 1},
               {second_image.id, 2}
             ]
    end

    test "reorder_product_images/2 rejects foreign image ids and keeps the original order" do
      product = product_fixture()
      other_product = product_fixture()

      first_image = product_image_fixture(product, %{filename: "first.jpg", display_order: 0})
      second_image = product_image_fixture(product, %{filename: "second.jpg", display_order: 1})

      foreign_image =
        product_image_fixture(other_product, %{filename: "foreign.jpg", display_order: 0})

      assert {:error, :invalid_product_image_order} =
               Products.reorder_product_images(product.id, [
                 second_image.id,
                 foreign_image.id
               ])

      assert Enum.map(Products.list_product_images(product), &{&1.id, &1.display_order}) == [
               {first_image.id, 0},
               {second_image.id, 1}
             ]
    end

    test "reorder_product_images/2 rejects unknown image ids" do
      product = product_fixture()
      first_image = product_image_fixture(product, %{filename: "first.jpg", display_order: 0})
      second_image = product_image_fixture(product, %{filename: "second.jpg", display_order: 1})

      assert {:error, :invalid_product_image_order} =
               Products.reorder_product_images(product.id, [second_image.id, first_image.id, -1])
    end

    test "reorder_product_images/2 rejects missing image ids" do
      product = product_fixture()
      _first_image = product_image_fixture(product, %{filename: "first.jpg", display_order: 0})
      second_image = product_image_fixture(product, %{filename: "second.jpg", display_order: 1})

      assert {:error, :invalid_product_image_order} =
               Products.reorder_product_images(product.id, [second_image.id])
    end

    test "reorder_product_images/2 rejects duplicate image ids" do
      product = product_fixture()
      first_image = product_image_fixture(product, %{filename: "first.jpg", display_order: 0})
      second_image = product_image_fixture(product, %{filename: "second.jpg", display_order: 1})

      assert {:error, :invalid_product_image_order} =
               Products.reorder_product_images(product.id, [
                 second_image.id,
                 second_image.id
               ])

      assert Enum.map(Products.list_product_images(product), &{&1.id, &1.display_order}) == [
               {first_image.id, 0},
               {second_image.id, 1}
             ]
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
          variant_name_vi: "Bien the sau",
          variant_name_en: "Variant later",
          display_order: 2,
          selling_price: 90_000
        })

      first_variant =
        product_variant_fixture(newer, %{
          variant_name_vi: "Bien the dau",
          variant_name_en: "Variant first",
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

  describe "admin product detail loading" do
    test "get_admin_product!/1 preloads collection and ordered product variants and images" do
      collection =
        collection_fixture(name_vi: "Bo suu tap A", name_en: "Collection A", nav_display_order: 0)

      product =
        product_fixture(
          collection: collection,
          slug: "detail-product",
          name_vi: "San pham chi tiet"
        )

      first_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the dau",
          variant_name_en: "First variant",
          display_order: 0
        })

      second_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the cung",
          variant_name_en: "Second same order",
          display_order: 0
        })

      later_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the sau",
          variant_name_en: "Later variant",
          display_order: 2
        })

      first_image =
        product_image_fixture(product, %{
          filename: "first-image.jpg",
          display_order: 0,
          has_thumbnail: true
        })

      second_image =
        product_image_fixture(product, %{
          filename: "second-image.jpg",
          display_order: 0,
          has_thumbnail: false
        })

      later_image =
        product_image_fixture(product, %{
          filename: "later-image.jpg",
          display_order: 2,
          has_thumbnail: true
        })

      _other_product_variant =
        product_variant_fixture(product_fixture(collection_id: nil), %{
          variant_name_vi: "Bien the khac",
          variant_name_en: "Other",
          display_order: 0
        })

      _other_product_image =
        product_image_fixture(product_fixture(collection_id: nil), %{
          filename: "other-image.jpg",
          display_order: 0,
          has_thumbnail: true
        })

      loaded_product = Products.get_admin_product!(product.id)

      assert Ecto.assoc_loaded?(loaded_product.collection)
      assert Ecto.assoc_loaded?(loaded_product.product_variants)
      assert Ecto.assoc_loaded?(loaded_product.product_images)
      assert loaded_product.collection.id == collection.id

      assert Enum.map(loaded_product.product_variants, & &1.id) == [
               first_variant.id,
               second_variant.id,
               later_variant.id
             ]

      assert Enum.map(loaded_product.product_images, & &1.id) == [
               first_image.id,
               second_image.id,
               later_image.id
             ]
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

    test "list_product_images_without_thumbnail/1 returns only pending images oldest first with a limit" do
      product = product_fixture()
      oldest = product_image_fixture(product, %{filename: "oldest.jpg", has_thumbnail: false})
      second = product_image_fixture(product, %{filename: "second.jpg", has_thumbnail: false})
      _created = product_image_fixture(product, %{filename: "created.jpg", has_thumbnail: true})

      assert Products.list_product_images_without_thumbnail(1) == [oldest]
      assert Products.list_product_images_without_thumbnail() == [oldest, second]
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

    test "add_product_image_upload/2 stores a managed upload and appends display_order" do
      product = product_fixture()
      _existing = product_image_fixture(product, %{filename: "existing.jpg", display_order: 0})
      upload_path = write_temp_upload!("product-image.jpeg", "jpeg-data")

      assert {:ok, product_image} =
               Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "product-image.jpeg"
               })

      assert product_image.product_id == product.id
      assert product_image.display_order == 1
      assert product_image.has_thumbnail == false
      assert product_image.filename =~ ~r/^#{product.id}_.+\.jpg$/
      assert {:ok, stored_path} = Uploads.product_image_path(product_image.filename)
      assert File.exists?(stored_path)
    end

    test "add_product_image_uploads/2 stores multiple managed uploads in order" do
      product = product_fixture()
      existing = product_image_fixture(product, %{filename: "existing.jpg", display_order: 0})
      first_upload_path = write_temp_upload!("first-product-image.jpg", "jpg-data-1")
      second_upload_path = write_temp_upload!("second-product-image.png", "png-data-2")

      assert {:ok, [first_product_image, second_product_image]} =
               Products.add_product_image_uploads(product, [
                 %{path: first_upload_path, client_name: "first-product-image.jpg"},
                 %{path: second_upload_path, client_name: "second-product-image.png"}
               ])

      assert first_product_image.display_order == 1
      assert second_product_image.display_order == 2
      assert first_product_image.filename =~ ~r/^#{product.id}_.+\.jpg$/
      assert second_product_image.filename =~ ~r/^#{product.id}_.+\.png$/

      assert Enum.map(Products.list_product_images(product), &{&1.id, &1.display_order}) == [
               {existing.id, 0},
               {first_product_image.id, 1},
               {second_product_image.id, 2}
             ]
    end

    test "add_product_image_upload/2 returns upload errors without creating a record" do
      product = product_fixture()
      upload_path = write_temp_upload!("product-image.gif", "gif-data")

      assert {:error, "unsupported file type"} =
               Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "product-image.gif"
               })

      assert Products.list_product_images(product) == []
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

    test "mark_product_image_thumbnail_generated/1 sets has_thumbnail to true" do
      product = product_fixture()
      product_image = product_image_fixture(product, %{has_thumbnail: false})

      assert {:ok, updated_product_image} =
               Products.mark_product_image_thumbnail_generated(product_image)

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

    test "delete_product_image/1 removes managed upload files" do
      product = product_fixture()
      upload_path = write_temp_upload!("delete-product-image.jpg", "jpg-data")

      assert {:ok, product_image} =
               Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "delete-product-image.jpg"
               })

      assert {:ok, stored_path} = Uploads.product_image_path(product_image.filename)
      thumbnail_filename = Uploads.thumbnail_filename(product_image.filename)
      assert {:ok, thumbnail_path} = Uploads.product_image_path(thumbnail_filename)
      File.write!(thumbnail_path, "thumb-data")

      assert File.exists?(stored_path)
      assert File.exists?(thumbnail_path)

      assert {:ok, %ProductImage{}} = Products.delete_product_image(product_image)

      refute File.exists?(stored_path)
      refute File.exists?(thumbnail_path)
    end

    test "delete_product_image/1 succeeds even when managed files are already missing" do
      product = product_fixture()
      upload_path = write_temp_upload!("delete-missing-product-image.jpg", "jpg-data")

      assert {:ok, product_image} =
               Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "delete-missing-product-image.jpg"
               })

      assert {:ok, stored_path} = Uploads.product_image_path(product_image.filename)

      assert {:ok, thumbnail_path} =
               Uploads.product_image_path(Uploads.thumbnail_filename(product_image.filename))

      File.rm!(stored_path)
      File.write!(thumbnail_path, "thumb-data")
      File.rm!(thumbnail_path)

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

    test "deleting a product removes managed product image files" do
      product = product_fixture()
      upload_path = write_temp_upload!("delete-product.jpg", "jpg-data")

      assert {:ok, product_image} =
               Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "delete-product.jpg"
               })

      assert {:ok, stored_path} = Uploads.product_image_path(product_image.filename)
      assert File.exists?(stored_path)

      assert {:ok, %Product{}} = Products.delete_product(product)

      refute File.exists?(stored_path)
    end

    test "delete_product_with_dependencies/1 deletes related variants and images but preserves other products" do
      product = product_fixture()
      other_product = product_fixture(slug: "other-product", collection_id: nil)
      removed_variant = product_variant_fixture(product)

      kept_variant =
        product_variant_fixture(other_product, variant_name_vi: "Khac", variant_name_en: "Other")

      removed_image = product_image_fixture(product, filename: "remove.jpg")
      kept_image = product_image_fixture(other_product, filename: "keep.jpg")

      assert {:ok, %Product{}} = Products.delete_product_with_dependencies(product)

      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product_variant!(removed_variant.id)
      end

      assert_raise Ecto.NoResultsError, fn -> Products.get_product_image!(removed_image.id) end
      assert Products.get_product!(other_product.id).id == other_product.id
      assert Products.get_product_variant!(kept_variant.id).id == kept_variant.id
      assert Products.get_product_image!(kept_image.id).id == kept_image.id
    end

    test "delete_product_with_dependencies/1 removes original and thumbnail files" do
      product = product_fixture()
      upload_path = write_temp_upload!("delete-product-with-deps.jpg", "jpg-data")

      assert {:ok, product_image} =
               Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "delete-product-with-deps.jpg"
               })

      assert {:ok, stored_path} = Uploads.product_image_path(product_image.filename)

      assert {:ok, thumbnail_path} =
               Uploads.product_image_path(Uploads.thumbnail_filename(product_image.filename))

      File.write!(thumbnail_path, "thumb-data")

      assert {:ok, %Product{}} = Products.delete_product_with_dependencies(product)

      refute File.exists?(stored_path)
      refute File.exists?(thumbnail_path)
    end

    test "delete_product_with_dependencies/1 succeeds when managed files are already missing" do
      product = product_fixture()
      upload_path = write_temp_upload!("delete-product-missing.jpg", "jpg-data")

      assert {:ok, product_image} =
               Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "delete-product-missing.jpg"
               })

      assert {:ok, stored_path} = Uploads.product_image_path(product_image.filename)

      assert {:ok, thumbnail_path} =
               Uploads.product_image_path(Uploads.thumbnail_filename(product_image.filename))

      File.rm!(stored_path)
      File.rm(thumbnail_path)

      assert {:ok, %Product{}} = Products.delete_product_with_dependencies(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "delete_product_with_dependencies/1 rejects unsafe filenames" do
      product = product_fixture()

      unsafe_image =
        %ProductImage{}
        |> ProductImage.changeset(%{
          product_id: product.id,
          filename: "../outside.jpg",
          display_order: 0,
          has_thumbnail: false
        })
        |> Repo.insert!()

      assert {:error, :invalid_filename} = Products.delete_product_with_dependencies(product)
      assert Products.get_product!(product.id).id == product.id
      assert Products.get_product_image!(unsafe_image.id).id == unsafe_image.id
    end
  end

  describe "product variants" do
    test "create_product_variant/1 requires bilingual names and selling_price" do
      changeset = Products.change_product_variant(%ProductVariant{}, %{})

      assert %{
               product_id: ["can't be blank"],
               variant_name_vi: ["can't be blank"],
               variant_name_en: ["can't be blank"],
               selling_price: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "create_product_variant/1 creates a valid bilingual variant" do
      product = product_fixture()

      assert {:ok, product_variant} =
               Products.create_product_variant(%{
                 product_id: product.id,
                 variant_name_vi: "PLA Do",
                 variant_name_en: "Red PLA",
                 production_cost: 10_000,
                 selling_price: 50_000,
                 stock_quantity: 5,
                 image_filename: "pla-red.jpg",
                 display_order: 0
               })

      assert product_variant.variant_name_vi == "PLA Do"
      assert product_variant.variant_name_en == "Red PLA"
    end

    test "create_product_variant/1 allows nil image_filename" do
      product = product_fixture()

      assert {:ok, product_variant} =
               Products.create_product_variant(%{
                 product_id: product.id,
                 variant_name_vi: "PLA Xam",
                 variant_name_en: "Gray PLA",
                 production_cost: 20_000,
                 selling_price: 70_000,
                 stock_quantity: 3,
                 image_filename: nil,
                 display_order: 0
               })

      assert product_variant.image_filename == nil
    end

    test "create_product_variant/1 enforces unique variant_name_vi per product" do
      product = product_fixture()
      product_variant_fixture(product, %{variant_name_vi: "PLA Do", variant_name_en: "Red PLA"})

      assert {:error, changeset} =
               Products.create_product_variant(
                 valid_product_variant_attributes(product, %{
                   variant_name_vi: "PLA Do",
                   variant_name_en: "Red PLA 2"
                 })
               )

      assert "has already been taken" in errors_on(changeset).variant_name_vi
    end

    test "create_product_variant/1 enforces unique variant_name_en per product" do
      product = product_fixture()

      product_variant_fixture(product, %{variant_name_vi: "PLA Den", variant_name_en: "Black PLA"})

      assert {:error, changeset} =
               Products.create_product_variant(
                 valid_product_variant_attributes(product, %{
                   variant_name_vi: "PLA Den 2",
                   variant_name_en: "Black PLA"
                 })
               )

      assert "has already been taken" in errors_on(changeset).variant_name_en
    end

    test "same bilingual names can exist under different products" do
      first_product = product_fixture()
      second_product = product_fixture()

      product_variant_fixture(first_product, %{
        variant_name_vi: "PLA Trang",
        variant_name_en: "White PLA"
      })

      assert {:ok, product_variant} =
               Products.create_product_variant(
                 valid_product_variant_attributes(second_product, %{
                   variant_name_vi: "PLA Trang",
                   variant_name_en: "White PLA"
                 })
               )

      assert product_variant.product_id == second_product.id
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
          variant_name_vi: "Den",
          variant_name_en: "Black",
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

    test "create_product_variant/1 validates bilingual name length" do
      product = product_fixture()
      long_name = String.duplicate("a", 161)

      changeset =
        Products.change_product_variant(%ProductVariant{}, %{
          product_id: product.id,
          variant_name_vi: long_name,
          variant_name_en: long_name,
          production_cost: 0,
          selling_price: 1,
          stock_quantity: 0,
          display_order: 0
        })

      assert "should be at most 160 character(s)" in errors_on(changeset).variant_name_vi
      assert "should be at most 160 character(s)" in errors_on(changeset).variant_name_en
    end

    test "list_product_variants/1 returns only variants for the given product ordered by display_order then inserted_at" do
      product = product_fixture()
      other_product = product_fixture()

      second =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the thu hai",
          variant_name_en: "Second",
          display_order: 1
        })

      first =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the dau",
          variant_name_en: "First",
          display_order: 0
        })

      _other =
        product_variant_fixture(other_product, %{
          variant_name_vi: "Bien the khac",
          variant_name_en: "Other",
          display_order: 0
        })

      assert Products.list_product_variants(product) == [first, second]
    end

    test "reorder_product_variants/2 updates display_order sequentially and accepts string ids" do
      product = product_fixture()

      first_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the dau",
          variant_name_en: "First",
          display_order: 0
        })

      second_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the hai",
          variant_name_en: "Second",
          display_order: 1
        })

      third_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the ba",
          variant_name_en: "Third",
          display_order: 2
        })

      assert {:ok, reordered_variants} =
               Products.reorder_product_variants(product.id, [
                 Integer.to_string(third_variant.id),
                 Integer.to_string(first_variant.id),
                 Integer.to_string(second_variant.id)
               ])

      assert Enum.map(reordered_variants, &{&1.id, &1.display_order}) == [
               {third_variant.id, 0},
               {first_variant.id, 1},
               {second_variant.id, 2}
             ]

      assert Enum.map(Products.list_product_variants(product), &{&1.id, &1.display_order}) == [
               {third_variant.id, 0},
               {first_variant.id, 1},
               {second_variant.id, 2}
             ]
    end

    test "reorder_product_variants/2 rejects foreign variant ids and keeps the original order" do
      product = product_fixture()
      other_product = product_fixture()

      first_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the dau",
          variant_name_en: "First",
          display_order: 0
        })

      second_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the hai",
          variant_name_en: "Second",
          display_order: 1
        })

      foreign_variant =
        product_variant_fixture(other_product, %{
          variant_name_vi: "Bien the ngoai",
          variant_name_en: "Foreign",
          display_order: 0
        })

      assert {:error, :invalid_product_variant_order} =
               Products.reorder_product_variants(product.id, [
                 second_variant.id,
                 foreign_variant.id
               ])

      assert Enum.map(Products.list_product_variants(product), &{&1.id, &1.display_order}) == [
               {first_variant.id, 0},
               {second_variant.id, 1}
             ]
    end

    test "reorder_product_variants/2 rejects unknown, missing, and duplicate ids" do
      product = product_fixture()

      first_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the dau",
          variant_name_en: "First",
          display_order: 0
        })

      second_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the hai",
          variant_name_en: "Second",
          display_order: 1
        })

      assert {:error, :invalid_product_variant_order} =
               Products.reorder_product_variants(product.id, [
                 second_variant.id,
                 first_variant.id,
                 -1
               ])

      assert {:error, :invalid_product_variant_order} =
               Products.reorder_product_variants(product.id, [second_variant.id])

      assert {:error, :invalid_product_variant_order} =
               Products.reorder_product_variants(product.id, [
                 second_variant.id,
                 second_variant.id
               ])

      assert Enum.map(Products.list_product_variants(product), &{&1.id, &1.display_order}) == [
               {first_variant.id, 0},
               {second_variant.id, 1}
             ]
    end

    test "next_product_variant_display_order/1 returns 0 when product has no variants" do
      product = product_fixture()

      assert Products.next_product_variant_display_order(product) == 0
    end

    test "next_product_variant_display_order/1 returns max display_order plus one" do
      product = product_fixture()

      product_variant_fixture(product, %{
        variant_name_vi: "Bien the dau",
        variant_name_en: "First",
        display_order: 0
      })

      product_variant_fixture(product, %{
        variant_name_vi: "Bien the cao hon",
        variant_name_en: "Higher",
        display_order: 4
      })

      product_variant_fixture(product, %{
        variant_name_vi: "Bien the chen giua",
        variant_name_en: "Middle",
        display_order: 2
      })

      assert Products.next_product_variant_display_order(product.id) == 5
    end

    test "update_product_variant/2 updates editable fields including bilingual names" do
      product = product_fixture()

      product_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Ban dau",
          variant_name_en: "Original"
        })

      assert {:ok, updated_product_variant} =
               Products.update_product_variant(product_variant, %{
                 variant_name_vi: "Da cap nhat",
                 variant_name_en: "Updated EN",
                 selling_price: 55_000,
                 display_order: 1
               })

      assert updated_product_variant.variant_name_vi == "Da cap nhat"
      assert updated_product_variant.variant_name_en == "Updated EN"
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

    test "delete_product_variant/1 does not delete product or other variants" do
      product = product_fixture()

      removed_variant =
        product_variant_fixture(product, %{variant_name_vi: "Xoa", variant_name_en: "Remove"})

      kept_variant =
        product_variant_fixture(product, %{variant_name_vi: "Giu", variant_name_en: "Keep"})

      assert {:ok, deleted_variant} = Products.delete_product_variant(removed_variant)
      assert deleted_variant.id == removed_variant.id
      assert Products.get_product!(product.id).id == product.id
      assert Products.list_product_variants(product) == [kept_variant]
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

  defp set_product_assets_path(_context) do
    previous = System.get_env("CA_HEO_SHOP_ASSETS_PATH")

    path =
      Path.join(
        System.tmp_dir!(),
        "ca_heo_shop_product_assets_#{System.unique_integer([:positive])}"
      )

    File.mkdir_p!(path)
    System.put_env("CA_HEO_SHOP_ASSETS_PATH", path)

    on_exit(fn ->
      if previous do
        System.put_env("CA_HEO_SHOP_ASSETS_PATH", previous)
      else
        System.delete_env("CA_HEO_SHOP_ASSETS_PATH")
      end

      File.rm_rf(path)
    end)

    :ok
  end

  defp write_temp_upload!(filename, contents) do
    path = Path.join(System.tmp_dir!(), "#{System.unique_integer([:positive])}-#{filename}")
    File.write!(path, contents)
    path
  end
end
