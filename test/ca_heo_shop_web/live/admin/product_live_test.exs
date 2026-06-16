defmodule CaHeoShopWeb.Admin.ProductLiveTest do
  use CaHeoShopWeb.ConnCase

  alias CaHeoShop.Uploads

  import CaHeoShop.CollectionsFixtures
  import CaHeoShop.ProductsFixtures
  import Phoenix.LiveViewTest

  setup :register_and_log_in_admin_user
  setup :set_collection_assets_path

  describe "product detail page" do
    test "renders admin product detail page with base product information", %{conn: conn} do
      collection =
        collection_fixture(
          name_vi: "Linh kien ban",
          name_en: "Desk Parts",
          nav_display_order: 0
        )

      product =
        product_fixture(
          collection: collection,
          slug: "magnetic-cable-clip",
          name_vi: "Kem cap nam cham",
          name_en: "Magnetic Cable Clip",
          description_vi: "Giu day gon gang tren ban lam viec.",
          description_en: "Keeps desk cables organized."
        )

      first_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the dau",
          variant_name_en: "First variant",
          display_order: 0,
          production_cost: 25_000,
          selling_price: 50_000,
          stock_quantity: 10,
          image_filename: "first-variant.jpg"
        })

      second_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the cung order",
          variant_name_en: "Second same order",
          display_order: 0,
          production_cost: 30_000,
          selling_price: 60_000,
          stock_quantity: 0,
          image_filename: nil
        })

      later_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the sau",
          variant_name_en: "Later variant",
          display_order: 2,
          production_cost: 40_000,
          selling_price: 70_000,
          stock_quantity: 5,
          image_filename: "later-variant.jpg"
        })

      selected_image =
        product_image_fixture(product, %{
          filename: "/images/storefront/magnetic-cable-clip.jpg",
          display_order: 0,
          has_thumbnail: true
        })

      no_thumbnail_image =
        product_image_fixture(product, %{
          filename: "/images/storefront/magnetic-cable-clip-detail.jpg",
          display_order: 1,
          has_thumbnail: false
        })

      _other_product_variant =
        product_variant_fixture(product_fixture(collection_id: nil), %{
          variant_name_vi: "Bien the khac",
          variant_name_en: "Other variant",
          display_order: 0
        })

      _other_product_image =
        product_image_fixture(product_fixture(collection_id: nil), %{
          filename: "/images/storefront/other-product.jpg",
          display_order: 0,
          has_thumbnail: true
        })

      {:ok, _view, html} = live(conn, ~p"/admin/products/#{product.id}")

      assert html =~ "Product detail"
      assert html =~ "Product summary"
      assert html =~ ~s(id="open-edit-product-dialog")
      assert html =~ ~r/>\s*Edit\s*<\/button>/
      assert html =~ "ID ##{product.id}"
      assert html =~ "Kem cap nam cham"
      assert html =~ "Magnetic Cable Clip"
      assert html =~ "/magnetic-cable-clip"
      assert html =~ "Linh kien ban"
      assert html =~ "Keeps desk cables organized."
      assert html =~ "Giu day gon gang tren ban lam viec."
      assert html =~ "Image preview"
      assert html =~ "Product images"
      assert html =~ "Upload image"
      assert html =~ "Copy"
      assert html =~ "Delete"
      assert html =~ ~s(phx-click="delete-product-image")
      assert html =~ ~s(data-confirm="Delete this product image?")
      assert html =~ "View original"
      assert html =~ "Drag"
      assert html =~ ~s(id="product-images-sortable")
      assert html =~ "/images/storefront/magnetic-cable-clip_500x500px.jpg"
      assert html =~ "/images/storefront/magnetic-cable-clip.jpg"
      assert html =~ "/images/storefront/magnetic-cable-clip-detail.jpg"
      assert html =~ "Order: 0"
      assert html =~ "Order: 1"
      assert html =~ "Thumbnail: yes"
      assert html =~ "Thumbnail: no"
      assert html =~ ~s(id="product-image-#{selected_image.id}")
      assert html =~ ~s(id="product-image-#{no_thumbnail_image.id}")
      assert html =~ ~s(data-copy-text="/images/storefront/magnetic-cable-clip.jpg")
      assert html =~ "/images/storefront/magnetic-cable-clip_500x500px.jpg"
      assert html =~ ~s(data-copy-text="/images/storefront/magnetic-cable-clip_500x500px.jpg")
      assert html =~ "Selected"
      assert html =~ ~s(src="/images/storefront/magnetic-cable-clip-detail.jpg")
      refute html =~ "/images/storefront/magnetic-cable-clip-detail_500x500px.jpg"
      refute html =~ "/images/storefront/other-product.jpg"
      assert html =~ "Product variants"
      assert html =~ ~s(id="open-new-variant-dialog")
      assert html =~ ~r/>\s*New\s*<\/button>/
      assert html =~ ~s(phx-click="open-edit-variant-dialog")
      assert html =~ ~s(id="product-variants-sortable")
      assert html =~ ~s(phx-hook="ProductVariantSortable")
      refute html =~ "New product variant"
      assert html =~ "First variant"
      assert html =~ "Second same order"
      assert html =~ "Later variant"
      assert html =~ "25,000 VND"
      assert html =~ "30,000 VND"
      assert html =~ "40,000 VND"
      assert html =~ "50,000 VND"
      assert html =~ "60,000 VND"
      assert html =~ "70,000 VND"
      assert html =~ "10"
      assert html =~ "0"
      assert html =~ "5"
      assert html =~ "first-variant.jpg"
      assert html =~ "later-variant.jpg"
      assert html =~ "—"
      assert html =~ "Edit"
      assert html =~ "Remove"
      assert html =~ "Drag"
      assert html =~ ~s(id="product-variant-#{first_variant.id}")
      assert html =~ ~s(id="product-variant-#{second_variant.id}")
      assert html =~ ~s(id="product-variant-#{later_variant.id}")
      assert html =~ ~s(phx-click="delete-product-variant")
      assert html =~ ~s(data-confirm="Remove this product variant?")
      assert html =~ "English description"
      assert html =~ "Vietnamese description"
      refute html =~ "Other variant"
      {english_pos, _} = :binary.match(html, "English description")
      {vietnamese_pos, _} = :binary.match(html, "Vietnamese description")
      assert english_pos < vietnamese_pos
      {content_pos, _} = :binary.match(html, "Product content")
      {variants_pos, _} = :binary.match(html, "Product variants")
      assert content_pos < variants_pos
      {preview_pos, _} = :binary.match(html, "Image preview")
      {images_pos, _} = :binary.match(html, "Product images")
      assert variants_pos < preview_pos
      assert variants_pos < images_pos
      assert preview_pos < images_pos
      refute html =~ "Create product"
      refute html =~ "No variants"

      {first_pos, _} = :binary.match(html, "First variant")
      {second_pos, _} = :binary.match(html, "Second same order")
      {later_pos, _} = :binary.match(html, "Later variant")
      assert first_pos < second_pos
      assert second_pos < later_pos
    end

    test "renders admin product detail empty variants state", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "no-variants",
          name_vi: "San pham khong co bien the",
          name_en: "Product without variants",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      {:ok, _view, html} = live(conn, ~p"/admin/products/#{product.id}")

      assert html =~ "Image preview"
      assert html =~ "No image"
      assert html =~ "Product images"
      assert html =~ "No product images"
      assert html =~ "Product variants"
      assert html =~ ~s(id="open-new-variant-dialog")
      assert html =~ ~r/>\s*New\s*<\/button>/
      refute html =~ "New product variant"
      assert html =~ "No variants"
      assert html =~ ~s(class="btn btn-xs" disabled)
      assert html =~ ">Copy</button>"
      assert html =~ "—"
      assert html =~ ~s(class="btn btn-ghost btn-sm" disabled)
      assert html =~ ">View original</button>"
      refute html =~ ~s(phx-click="open-edit-variant-dialog")
      refute html =~ ~s(phx-click="delete-product-variant")
    end
  end

  describe "product summary dialog" do
    test "clicking edit product opens the summary dialog", %{conn: conn} do
      collection =
        collection_fixture(
          name_vi: "Bo suu tap cu",
          name_en: "Old collection",
          nav_display_order: 1
        )

      _other_collection =
        collection_fixture(
          name_vi: "Bo suu tap moi",
          name_en: "New collection",
          nav_display_order: 0
        )

      product =
        product_fixture(
          collection: collection,
          slug: "edit-product-summary",
          name_vi: "Ten san pham",
          name_en: "Product name",
          description_vi: "Mo ta viet",
          description_en: "English description"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      html =
        view
        |> element("#open-edit-product-dialog")
        |> render_click()

      assert html =~ "Edit Product"
      assert html =~ "Collection"
      assert html =~ "Slug"
      assert html =~ "Vietnamese name"
      assert html =~ "English name"
      assert html =~ "Update product"
      assert html =~ "Cancel"
      assert html =~ "No collection"
      assert html =~ "Bo suu tap cu"
      assert html =~ "Bo suu tap moi"
      assert html =~ ~s(name="product[collection_id]")
      assert html =~ ~s(name="product[slug]")
      assert html =~ ~s(name="product[name_vi]")
      assert html =~ ~s(name="product[name_en]")
      refute html =~ ~s(name="product[description_vi]")
      refute html =~ ~s(name="product[description_en]")
      refute html =~ ~s(name="product_variant[production_cost]")
      refute html =~ ~s(name="product_variant[image_filename]")
    end

    test "updates product summary from the detail dialog and ignores description params", %{
      conn: conn
    } do
      old_collection =
        collection_fixture(
          name_vi: "Bo suu tap cu",
          name_en: "Old collection",
          nav_display_order: 1
        )

      new_collection =
        collection_fixture(
          name_vi: "Bo suu tap moi",
          name_en: "New collection",
          nav_display_order: 0
        )

      product =
        product_fixture(
          collection: old_collection,
          slug: "old-summary-slug",
          name_vi: "Ten cu",
          name_en: "Old name",
          description_vi: "Mo ta viet cu",
          description_en: "Old description"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-edit-product-dialog")
        |> render_click()

      html =
        render_submit(view, "save-product-summary", %{
          "product" => %{
            "collection_id" => Integer.to_string(new_collection.id),
            "slug" => "new-summary-slug",
            "name_vi" => "Ten moi",
            "name_en" => "New name",
            "description_vi" => "Bi bo qua",
            "description_en" => "Ignored"
          }
        })

      assert html =~ "Product updated successfully."
      refute html =~ "Edit Product</h2>"
      assert html =~ "Bo suu tap moi"
      assert html =~ "/new-summary-slug"
      assert html =~ "Ten moi"
      assert html =~ "New name"
      assert html =~ "Mo ta viet cu"
      assert html =~ "Old description"

      updated_product = CaHeoShop.Products.get_product!(product.id)
      assert updated_product.collection_id == new_collection.id
      assert updated_product.slug == "new-summary-slug"
      assert updated_product.name_vi == "Ten moi"
      assert updated_product.name_en == "New name"
      assert updated_product.description_vi == "Mo ta viet cu"
      assert updated_product.description_en == "Old description"
    end

    test "product summary update can set collection to no collection", %{conn: conn} do
      collection =
        collection_fixture(
          name_vi: "Bo suu tap co san",
          name_en: "Existing collection",
          nav_display_order: 0
        )

      product =
        product_fixture(
          collection: collection,
          slug: "remove-collection",
          name_vi: "San pham",
          name_en: "Product"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-edit-product-dialog")
        |> render_click()

      html =
        view
        |> form("#product-summary-form",
          product: %{
            collection_id: "",
            slug: "remove-collection",
            name_vi: "San pham",
            name_en: "Product"
          }
        )
        |> render_submit()

      assert html =~ "Product updated successfully."
      assert html =~ "No collection"
      assert CaHeoShop.Products.get_product!(product.id).collection_id == nil
    end

    test "invalid product summary submit keeps the dialog open and shows errors", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "valid-summary-slug",
          name_vi: "Ten hop le",
          name_en: "Valid name"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-edit-product-dialog")
        |> render_click()

      html =
        view
        |> form("#product-summary-form",
          product: %{
            collection_id: "",
            slug: "invalid slug",
            name_vi: "",
            name_en: ""
          }
        )
        |> render_submit()

      assert html =~ "Edit Product"
      assert html =~ "can&#39;t be blank"
      assert html =~ "has invalid format"

      unchanged_product = CaHeoShop.Products.get_product!(product.id)
      assert unchanged_product.slug == "valid-summary-slug"
      assert unchanged_product.name_vi == "Ten hop le"
      assert unchanged_product.name_en == "Valid name"
    end
  end

  describe "product content dialog" do
    test "clicking edit product content opens the content dialog", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "edit-product-content",
          name_vi: "Ten san pham",
          name_en: "Product name",
          description_vi: "Mo ta viet",
          description_en: "English description"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      html =
        view
        |> element("#open-edit-product-content-dialog")
        |> render_click()

      assert html =~ "Edit Product Content"
      assert html =~ "English description"
      assert html =~ "Vietnamese description"
      assert html =~ "Update content"
      assert html =~ "Cancel"
      assert html =~ ~s(name="product[description_en]")
      assert html =~ ~s(name="product[description_vi]")
      refute html =~ ~s(name="product[collection_id]")
      refute html =~ ~s(name="product[slug]")
      refute html =~ ~s(name="product[name_vi]")
      refute html =~ ~s(name="product[name_en]")
    end

    test "updates product content from the detail dialog and ignores summary params", %{
      conn: conn
    } do
      product =
        product_fixture(
          collection_id: nil,
          slug: "content-update",
          name_vi: "Ten cu",
          name_en: "Old name",
          description_vi: "Mo ta viet cu",
          description_en: "Old description"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-edit-product-content-dialog")
        |> render_click()

      html =
        render_submit(view, "save-product-content", %{
          "product" => %{
            "description_vi" => "Mo ta viet moi",
            "description_en" => "New description",
            "slug" => "ignored-slug",
            "name_vi" => "Ignored vi",
            "name_en" => "Ignored en"
          }
        })

      assert html =~ "Product content updated successfully."
      refute html =~ "Edit Product Content"
      assert html =~ "Mo ta viet moi"
      assert html =~ "New description"
      assert html =~ "/content-update"
      assert html =~ "Ten cu"
      assert html =~ "Old name"

      updated_product = CaHeoShop.Products.get_product!(product.id)
      assert updated_product.description_vi == "Mo ta viet moi"
      assert updated_product.description_en == "New description"
      assert updated_product.slug == "content-update"
      assert updated_product.name_vi == "Ten cu"
      assert updated_product.name_en == "Old name"
    end

    test "product content update can clear descriptions", %{conn: conn} do
      product =
        product_fixture(
          description_vi: "Mo ta viet cu",
          description_en: "Old description"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-edit-product-content-dialog")
        |> render_click()

      html =
        view
        |> form("#product-content-form",
          product: %{
            description_vi: "",
            description_en: ""
          }
        )
        |> render_submit()

      assert html =~ "Product content updated successfully."
      assert html =~ "No description"

      updated_product = CaHeoShop.Products.get_product!(product.id)
      assert updated_product.description_vi == nil
      assert updated_product.description_en == nil
    end

    test "invalid product content submit keeps the dialog open and shows errors", %{conn: conn} do
      product =
        product_fixture(
          description_vi: "Mo ta viet cu",
          description_en: "Old description"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-edit-product-content-dialog")
        |> render_click()

      long_text = String.duplicate("a", 10_001)

      html =
        view
        |> form("#product-content-form",
          product: %{
            description_vi: long_text,
            description_en: long_text
          }
        )
        |> render_submit()

      assert html =~ "Edit Product Content"
      assert html =~ "should be at most 10000 character(s)"

      unchanged_product = CaHeoShop.Products.get_product!(product.id)
      assert unchanged_product.description_vi == "Mo ta viet cu"
      assert unchanged_product.description_en == "Old description"
    end
  end

  describe "product images" do
    test "selecting a product image updates the preview and selected state", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "selectable-images",
          name_vi: "San pham co anh",
          name_en: "Selectable images",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      first_image =
        product_image_fixture(product, %{
          filename: "/images/storefront/selectable-primary.jpg",
          display_order: 0,
          has_thumbnail: true
        })

      second_image =
        product_image_fixture(product, %{
          filename: "/images/storefront/selectable-secondary.jpg",
          display_order: 1,
          has_thumbnail: false
        })

      {:ok, view, html} = live(conn, ~p"/admin/products/#{product.id}")

      assert html =~ "/images/storefront/selectable-primary_500x500px.jpg"
      assert html =~ ~s(data-copy-text="/images/storefront/selectable-primary.jpg")
      assert html =~ ~s(data-copy-text="/images/storefront/selectable-primary_500x500px.jpg")
      refute html =~ ~s(data-copy-text="/images/storefront/selectable-secondary.jpg")

      html =
        view
        |> element(
          ~s(button[phx-click="select-product-image"][phx-value-id="#{second_image.id}"])
        )
        |> render_click()

      assert html =~ "/images/storefront/selectable-secondary.jpg"
      assert html =~ ~s(data-copy-text="/images/storefront/selectable-secondary.jpg")
      assert html =~ ~s(src="/images/storefront/selectable-secondary.jpg")
      refute html =~ "/images/storefront/selectable-secondary_500x500px.jpg"
      assert html =~ ~s(class="btn btn-xs" disabled)
      assert html =~ ">Copy</button>"
      assert html =~ "—"

      {selected_badge_pos, _} = :binary.match(html, "Selected")
      {secondary_pos, _} = :binary.match(html, "selectable-secondary.jpg")
      assert selected_badge_pos > secondary_pos

      html =
        view
        |> element(~s(button[phx-click="select-product-image"][phx-value-id="#{first_image.id}"]))
        |> render_click()

      assert html =~ "/images/storefront/selectable-primary_500x500px.jpg"
      assert html =~ ~s(data-copy-text="/images/storefront/selectable-primary.jpg")
      assert html =~ ~s(data-copy-text="/images/storefront/selectable-primary_500x500px.jpg")
    end

    test "reordering product images updates list order and keeps the selected image", %{
      conn: conn
    } do
      product =
        product_fixture(
          collection_id: nil,
          slug: "reorderable-images",
          name_vi: "San pham sap xep anh",
          name_en: "Reorderable images",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      first_image =
        product_image_fixture(product, %{
          filename: "/images/storefront/reorder-first.jpg",
          display_order: 0,
          has_thumbnail: true
        })

      second_image =
        product_image_fixture(product, %{
          filename: "/images/storefront/reorder-second.jpg",
          display_order: 1,
          has_thumbnail: true
        })

      third_image =
        product_image_fixture(product, %{
          filename: "/images/storefront/reorder-third.jpg",
          display_order: 2,
          has_thumbnail: false
        })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element(
          ~s(button[phx-click="select-product-image"][phx-value-id="#{second_image.id}"])
        )
        |> render_click()

      html =
        view
        |> element("#product-images-sortable")
        |> render_hook("reorder-product-images", %{
          "ids" => [
            Integer.to_string(third_image.id),
            Integer.to_string(second_image.id),
            Integer.to_string(first_image.id)
          ]
        })

      assert html =~ "Product image order updated."
      assert html =~ ~s(data-copy-text="/images/storefront/reorder-second.jpg")

      {third_row_pos, _} = :binary.match(html, ~s(id="product-image-#{third_image.id}"))
      {second_row_pos, _} = :binary.match(html, ~s(id="product-image-#{second_image.id}"))
      {first_row_pos, _} = :binary.match(html, ~s(id="product-image-#{first_image.id}"))
      assert third_row_pos < second_row_pos
      assert second_row_pos < first_row_pos

      assert html =~ "Order: 0"
      assert html =~ "Order: 1"
      assert html =~ "Order: 2"

      assert Enum.map(CaHeoShop.Products.list_product_images(product), &{&1.id, &1.display_order}) ==
               [
                 {third_image.id, 0},
                 {second_image.id, 1},
                 {first_image.id, 2}
               ]
    end

    test "invalid product image reorder shows an error and keeps the current order", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "invalid-reorder",
          name_vi: "San pham sap xep loi",
          name_en: "Invalid reorder",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      first_image =
        product_image_fixture(product, %{
          filename: "/images/storefront/invalid-first.jpg",
          display_order: 0,
          has_thumbnail: true
        })

      second_image =
        product_image_fixture(product, %{
          filename: "/images/storefront/invalid-second.jpg",
          display_order: 1,
          has_thumbnail: true
        })

      html =
        live(conn, ~p"/admin/products/#{product.id}")
        |> then(fn {:ok, view, _html} ->
          view
          |> element("#product-images-sortable")
          |> render_hook("reorder-product-images", %{
            "ids" => [Integer.to_string(second_image.id), Integer.to_string(second_image.id)]
          })
        end)

      assert html =~ "Could not reorder product images."

      {first_row_pos, _} = :binary.match(html, ~s(id="product-image-#{first_image.id}"))
      {second_row_pos, _} = :binary.match(html, ~s(id="product-image-#{second_image.id}"))
      assert first_row_pos < second_row_pos

      assert Enum.map(CaHeoShop.Products.list_product_images(product), &{&1.id, &1.display_order}) ==
               [
                 {first_image.id, 0},
                 {second_image.id, 1}
               ]
    end

    test "invalid product image selection is ignored safely", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "invalid-image-selection",
          name_vi: "San pham an toan",
          name_en: "Safe product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      product_image_fixture(product, %{
        filename: "/images/storefront/safe-primary.jpg",
        display_order: 0,
        has_thumbnail: true
      })

      other_image =
        product_image_fixture(product_fixture(collection_id: nil), %{
          filename: "/images/storefront/foreign-image.jpg",
          display_order: 0,
          has_thumbnail: true
        })

      {:ok, view, html} = live(conn, ~p"/admin/products/#{product.id}")

      assert html =~ ~s(data-copy-text="/images/storefront/safe-primary.jpg")
      refute html =~ "/images/storefront/foreign-image.jpg"

      html =
        view
        |> render_click("select-product-image", %{"id" => Integer.to_string(other_image.id)})

      assert html =~ ~s(data-copy-text="/images/storefront/safe-primary.jpg")
      refute html =~ "/images/storefront/foreign-image.jpg"
    end

    test "clicking upload image opens the dialog", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "upload-product-image-dialog",
          name_vi: "San pham tai anh",
          name_en: "Upload product image dialog"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      html =
        view
        |> element("#open-upload-product-image-dialog")
        |> render_click()

      assert html =~ "Upload product image"
      assert html =~ ~s(id="product-image-upload-form")
      assert html =~ "Upload image"
      assert html =~ "Cancel"
      assert html =~ "Maximum 10 files. Maximum file size: 2MB each."
    end

    test "uploads a product image from the detail page and selects it when it is the first image",
         %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "upload-product-image",
          name_vi: "San pham tai anh moi",
          name_en: "Upload product image"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-upload-product-image-dialog")
        |> render_click()

      upload =
        file_input(view, "#product-image-upload-form", :product_image, [
          %{name: "product-upload.jpeg", content: "fake-jpeg", type: "image/jpeg"}
        ])

      assert render_upload(upload, "product-upload.jpeg") =~ "100%"

      html =
        view
        |> form("#product-image-upload-form", %{})
        |> render_submit()

      assert html =~ "Product image uploaded successfully."
      refute html =~ ~s(id="product-image-upload-form")
      refute html =~ "No product images"
      refute html =~ "No image"

      [uploaded_image] = CaHeoShop.Products.list_product_images(product)
      assert uploaded_image.display_order == 0
      assert uploaded_image.has_thumbnail == false
      assert uploaded_image.filename =~ ~r/^#{product.id}_.+\.jpg$/

      assert html =~ ~s(id="product-image-#{uploaded_image.id}")
      assert html =~ ~s(src="/product_images/#{uploaded_image.filename}")
      assert html =~ ~s(href="/product_images/#{uploaded_image.filename}")
      assert html =~ uploaded_image.filename
      assert html =~ "Selected"

      assert {:ok, image_path} = Uploads.product_image_path(uploaded_image.filename)
      assert File.exists?(image_path)
    end

    test "submitting product image upload without selecting a file shows an error", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "upload-product-image-empty",
          name_vi: "San pham tai anh rong",
          name_en: "Upload empty product image"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-upload-product-image-dialog")
        |> render_click()

      html =
        view
        |> form("#product-image-upload-form", %{})
        |> render_submit()

      assert html =~ "Please select an image file to upload."
      assert html =~ "Upload product image"
      assert CaHeoShop.Products.list_product_images(product) == []
    end

    test "rejects unsupported product image uploads", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "upload-product-image-invalid",
          name_vi: "San pham tai anh sai",
          name_en: "Upload invalid product image"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-upload-product-image-dialog")
        |> render_click()

      upload =
        file_input(view, "#product-image-upload-form", :product_image, [
          %{name: "product-upload.gif", content: "fake-gif", type: "image/gif"}
        ])

      assert {:error, [[_ref, :not_accepted]]} = render_upload(upload, "product-upload.gif")
    end

    test "rejects selecting more than 10 product image uploads", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "too-many-product-image-uploads",
          name_vi: "San pham qua nhieu anh",
          name_en: "Too many product images"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-upload-product-image-dialog")
        |> render_click()

      upload_entries =
        for index <- 1..11 do
          %{name: "product-upload-#{index}.jpg", content: "jpg-data-#{index}", type: "image/jpeg"}
        end

      upload = file_input(view, "#product-image-upload-form", :product_image, upload_entries)

      assert {:error, [[_ref, :too_many_files]]} = render_upload(upload, "product-upload-11.jpg")
    end

    test "deletes the selected product image from the detail page", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "delete-product-image",
          name_vi: "San pham xoa anh",
          name_en: "Delete product image product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      first_upload_path = write_temp_upload!("delete-first.jpg", "jpg-data-1")
      second_upload_path = write_temp_upload!("delete-second.png", "png-data-2")

      assert {:ok, first_image} =
               CaHeoShop.Products.add_product_image_upload(product, %{
                 path: first_upload_path,
                 client_name: "delete-first.jpg"
               })

      assert {:ok, second_image} =
               CaHeoShop.Products.add_product_image_upload(product, %{
                 path: second_upload_path,
                 client_name: "delete-second.png"
               })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      html =
        view
        |> render_click("delete-product-image", %{"id" => Integer.to_string(first_image.id)})

      assert html =~ "Product image deleted successfully."
      refute html =~ ~s(id="product-image-#{first_image.id}")
      assert html =~ ~s(id="product-image-#{second_image.id}")
      assert html =~ "Selected"
      refute html =~ ~s(data-copy-text="#{first_image.filename}")
      assert html =~ ~s(data-copy-text="#{second_image.filename}")

      assert_raise Ecto.NoResultsError, fn ->
        CaHeoShop.Products.get_product_image!(first_image.id)
      end
    end

    test "deleting the last product image clears the preview state", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "delete-last-product-image",
          name_vi: "San pham xoa anh cuoi",
          name_en: "Delete last product image product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      upload_path = write_temp_upload!("delete-last.jpg", "jpg-data")

      assert {:ok, product_image} =
               CaHeoShop.Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "delete-last.jpg"
               })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      html =
        view
        |> render_click("delete-product-image", %{"id" => Integer.to_string(product_image.id)})

      assert html =~ "Product image deleted successfully."
      assert html =~ "No product images"
      assert html =~ "No image"
      refute html =~ ~s(phx-click="delete-product-image")
      refute html =~ ~s(data-copy-text="#{product_image.filename}")
    end

    test "deleting a foreign product image is ignored safely", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "safe-delete-product-image",
          name_vi: "San pham xoa anh an toan",
          name_en: "Safe delete product image product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      own_upload_path = write_temp_upload!("own-delete-safe.jpg", "jpg-data")
      foreign_upload_path = write_temp_upload!("foreign-delete-safe.jpg", "jpg-data")

      assert {:ok, own_image} =
               CaHeoShop.Products.add_product_image_upload(product, %{
                 path: own_upload_path,
                 client_name: "own-delete-safe.jpg"
               })

      assert {:ok, foreign_image} =
               CaHeoShop.Products.add_product_image_upload(product_fixture(collection_id: nil), %{
                 path: foreign_upload_path,
                 client_name: "foreign-delete-safe.jpg"
               })

      {:ok, view, html} = live(conn, ~p"/admin/products/#{product.id}")

      assert html =~ ~s(id="product-image-#{own_image.id}")

      html =
        view
        |> render_click("delete-product-image", %{"id" => Integer.to_string(foreign_image.id)})

      assert html =~ "Product image not found."
      assert html =~ ~s(id="product-image-#{own_image.id}")

      assert %CaHeoShop.Products.ProductImage{} =
               CaHeoShop.Products.get_product_image!(foreign_image.id)
    end
  end

  describe "product variants" do
    test "clicking new variant opens the dialog with the next display order", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "variant-dialog",
          name_vi: "San pham mo dialog",
          name_en: "Variant dialog product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      product_variant_fixture(product, %{
        variant_name_vi: "Bien the truoc",
        variant_name_en: "Previous variant",
        display_order: 4
      })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      html =
        view
        |> element("#open-new-variant-dialog")
        |> render_click()

      assert html =~ "New product variant"
      assert html =~ "Vietnamese variant name"
      assert html =~ "English variant name"
      assert html =~ "Production cost"
      assert html =~ "Selling price"
      assert html =~ "Stock quantity"
      assert html =~ "Image filename"
      assert html =~ "Display order"
      assert html =~ "Create variant"
      assert html =~ "Cancel"
      assert html =~ ~s(name="product_variant[display_order]")
      assert html =~ ~s(value="5")
    end

    test "clicking edit opens the dialog with existing variant values", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "edit-variant-dialog",
          name_vi: "San pham sua bien the",
          name_en: "Edit variant dialog product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      variant =
        product_variant_fixture(product, %{
          variant_name_vi: "PLA Tim",
          variant_name_en: "Purple PLA",
          production_cost: 12_000,
          selling_price: 35_000,
          stock_quantity: 9,
          image_filename: "purple.jpg",
          display_order: 2
        })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      html =
        view
        |> element(~s(button[phx-click="open-edit-variant-dialog"][phx-value-id="#{variant.id}"]))
        |> render_click()

      assert html =~ "Edit product variant"
      assert html =~ "Update variant"
      assert html =~ ~s(value="PLA Tim")
      assert html =~ ~s(value="Purple PLA")
      assert html =~ ~s(value="12000")
      assert html =~ ~s(value="35000")
      assert html =~ ~s(value="9")
      assert html =~ ~s(value="purple.jpg")
      assert html =~ ~s(value="2")
    end

    test "creates a product variant from the detail dialog and ignores submitted product_id", %{
      conn: conn
    } do
      product =
        product_fixture(
          collection_id: nil,
          slug: "create-variant",
          name_vi: "San pham tao bien the",
          name_en: "Create variant product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      other_product = product_fixture(collection_id: nil, slug: "other-variant-parent")

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-new-variant-dialog")
        |> render_click()

      html =
        render_submit(view, "save-variant", %{
          "product_variant" => %{
            "product_id" => Integer.to_string(other_product.id),
            "variant_name_vi" => "PLA Xanh",
            "variant_name_en" => "Blue PLA",
            "production_cost" => "15000",
            "selling_price" => "45000",
            "stock_quantity" => "7",
            "image_filename" => "",
            "display_order" => "0"
          }
        })

      assert html =~ "Product variant created successfully."
      refute html =~ "New product variant"
      refute html =~ "No variants"
      assert html =~ "PLA Xanh"
      assert html =~ "Blue PLA"
      assert html =~ "15,000 VND"
      assert html =~ "45,000 VND"
      assert html =~ "7"
      assert html =~ "—"
      assert html =~ "Edit"
      assert html =~ "Remove"

      [created_variant] = CaHeoShop.Products.list_product_variants(product)
      assert created_variant.product_id == product.id
      assert created_variant.image_filename == nil
      assert CaHeoShop.Products.list_product_variants(other_product) == []
    end

    test "updates a product variant from the detail dialog and ignores submitted product_id", %{
      conn: conn
    } do
      product =
        product_fixture(
          collection_id: nil,
          slug: "update-variant",
          name_vi: "San pham cap nhat bien the",
          name_en: "Update variant product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      other_product = product_fixture(collection_id: nil, slug: "other-update-parent")

      variant =
        product_variant_fixture(product, %{
          variant_name_vi: "PLA Cam",
          variant_name_en: "Orange PLA",
          production_cost: 11_000,
          selling_price: 31_000,
          stock_quantity: 4,
          image_filename: "orange.jpg",
          display_order: 1
        })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element(~s(button[phx-click="open-edit-variant-dialog"][phx-value-id="#{variant.id}"]))
        |> render_click()

      html =
        render_submit(view, "save-variant", %{
          "product_variant" => %{
            "product_id" => Integer.to_string(other_product.id),
            "variant_name_vi" => "PLA Cam Moi",
            "variant_name_en" => "Updated Orange PLA",
            "production_cost" => "17000",
            "selling_price" => "52000",
            "stock_quantity" => "6",
            "image_filename" => "",
            "display_order" => "3"
          }
        })

      assert html =~ "Product variant updated successfully."
      refute html =~ "Edit product variant"
      assert html =~ "PLA Cam Moi"
      assert html =~ "Updated Orange PLA"
      assert html =~ "17,000 VND"
      assert html =~ "52,000 VND"
      assert html =~ "6"
      assert html =~ "—"

      updated_variant = CaHeoShop.Products.get_product_variant!(variant.id)
      assert updated_variant.product_id == product.id
      assert updated_variant.variant_name_vi == "PLA Cam Moi"
      assert updated_variant.variant_name_en == "Updated Orange PLA"
      assert updated_variant.production_cost == 17_000
      assert updated_variant.selling_price == 52_000
      assert updated_variant.stock_quantity == 6
      assert updated_variant.display_order == 3
      assert updated_variant.image_filename == nil
    end

    test "invalid product variant submit keeps the dialog open and shows errors", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "invalid-variant",
          name_vi: "San pham loi bien the",
          name_en: "Invalid variant product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element("#open-new-variant-dialog")
        |> render_click()

      html =
        view
        |> form("#product-variant-form",
          product_variant: %{
            variant_name_vi: "",
            variant_name_en: "",
            production_cost: "-1",
            selling_price: "",
            stock_quantity: "-1",
            image_filename: "",
            display_order: "-1"
          }
        )
        |> render_submit()

      assert html =~ "New product variant"
      assert html =~ "can&#39;t be blank"
      assert html =~ "must be greater than or equal to 0"
      assert CaHeoShop.Products.list_product_variants(product) == []
    end

    test "invalid product variant edit keeps the dialog open and preserves existing data", %{
      conn: conn
    } do
      product =
        product_fixture(
          collection_id: nil,
          slug: "invalid-edit-variant",
          name_vi: "San pham sua loi",
          name_en: "Invalid edit variant product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      variant =
        product_variant_fixture(product, %{
          variant_name_vi: "PLA Nau",
          variant_name_en: "Brown PLA",
          selling_price: 25_000
        })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element(~s(button[phx-click="open-edit-variant-dialog"][phx-value-id="#{variant.id}"]))
        |> render_click()

      html =
        view
        |> form("#product-variant-form",
          product_variant: %{
            variant_name_vi: "",
            variant_name_en: "",
            production_cost: "-1",
            selling_price: "",
            stock_quantity: "-1",
            image_filename: "",
            display_order: "-1"
          }
        )
        |> render_submit()

      assert html =~ "Edit product variant"
      assert html =~ "can&#39;t be blank"
      assert html =~ "must be greater than or equal to 0"

      unchanged_variant = CaHeoShop.Products.get_product_variant!(variant.id)
      assert unchanged_variant.variant_name_vi == "PLA Nau"
      assert unchanged_variant.variant_name_en == "Brown PLA"
      assert unchanged_variant.selling_price == 25_000
    end

    test "editing a foreign product variant is ignored safely", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "safe-edit-variant",
          name_vi: "San pham an toan sua",
          name_en: "Safe edit variant product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      foreign_variant =
        product_variant_fixture(product_fixture(collection_id: nil), %{
          variant_name_vi: "PLA La",
          variant_name_en: "Foreign PLA"
        })

      {:ok, view, html} = live(conn, ~p"/admin/products/#{product.id}")

      refute html =~ "Edit product variant"

      html =
        view
        |> render_click("open-edit-variant-dialog", %{
          "id" => Integer.to_string(foreign_variant.id)
        })

      assert html =~ "Product variant not found."
      refute html =~ "Edit product variant"
    end

    test "reordering product variants updates row order and keeps the selected edit variant", %{
      conn: conn
    } do
      product =
        product_fixture(
          collection_id: nil,
          slug: "reorder-variants",
          name_vi: "San pham sap xep bien the",
          name_en: "Reorder variants product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      first_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the dau",
          variant_name_en: "First variant",
          display_order: 0
        })

      second_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the hai",
          variant_name_en: "Second variant",
          display_order: 1
        })

      third_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the ba",
          variant_name_en: "Third variant",
          display_order: 2
        })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element(
          ~s(button[phx-click="open-edit-variant-dialog"][phx-value-id="#{second_variant.id}"])
        )
        |> render_click()

      html =
        view
        |> element("#product-variants-sortable")
        |> render_hook("reorder-product-variants", %{
          "ids" => [
            Integer.to_string(third_variant.id),
            Integer.to_string(second_variant.id),
            Integer.to_string(first_variant.id)
          ]
        })

      assert html =~ "Product variant order updated."
      assert html =~ "Edit product variant"
      assert html =~ ~s(value="Second variant")

      {third_row_pos, _} = :binary.match(html, ~s(id="product-variant-#{third_variant.id}"))
      {second_row_pos, _} = :binary.match(html, ~s(id="product-variant-#{second_variant.id}"))
      {first_row_pos, _} = :binary.match(html, ~s(id="product-variant-#{first_variant.id}"))
      assert third_row_pos < second_row_pos
      assert second_row_pos < first_row_pos

      assert Enum.map(
               CaHeoShop.Products.list_product_variants(product),
               &{&1.id, &1.display_order}
             ) ==
               [
                 {third_variant.id, 0},
                 {second_variant.id, 1},
                 {first_variant.id, 2}
               ]
    end

    test "invalid product variant reorder shows an error and keeps current order", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "invalid-reorder-variants",
          name_vi: "San pham sap xep loi bien the",
          name_en: "Invalid reorder variants product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      first_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the dau",
          variant_name_en: "First variant",
          display_order: 0
        })

      second_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "Bien the hai",
          variant_name_en: "Second variant",
          display_order: 1
        })

      html =
        live(conn, ~p"/admin/products/#{product.id}")
        |> then(fn {:ok, view, _html} ->
          view
          |> element("#product-variants-sortable")
          |> render_hook("reorder-product-variants", %{
            "ids" => [Integer.to_string(second_variant.id), Integer.to_string(second_variant.id)]
          })
        end)

      assert html =~ "Could not reorder product variants."

      {first_row_pos, _} = :binary.match(html, ~s(id="product-variant-#{first_variant.id}"))
      {second_row_pos, _} = :binary.match(html, ~s(id="product-variant-#{second_variant.id}"))
      assert first_row_pos < second_row_pos

      assert Enum.map(
               CaHeoShop.Products.list_product_variants(product),
               &{&1.id, &1.display_order}
             ) ==
               [
                 {first_variant.id, 0},
                 {second_variant.id, 1}
               ]
    end

    test "deletes a product variant from the detail page", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "delete-variant",
          name_vi: "San pham xoa bien the",
          name_en: "Delete variant product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      removed_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "PLA Hong",
          variant_name_en: "Pink PLA"
        })

      kept_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "PLA Xanh La",
          variant_name_en: "Green PLA"
        })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      html =
        view
        |> render_click("delete-product-variant", %{"id" => Integer.to_string(removed_variant.id)})

      assert html =~ "Product variant removed successfully."
      refute html =~ "PLA Hong"
      refute html =~ "Pink PLA"
      assert html =~ "PLA Xanh La"
      assert html =~ "Green PLA"

      assert_raise Ecto.NoResultsError, fn ->
        CaHeoShop.Products.get_product_variant!(removed_variant.id)
      end

      assert Enum.map(CaHeoShop.Products.list_product_variants(product), & &1.id) == [
               kept_variant.id
             ]
    end

    test "deleting the last product variant shows empty state", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "delete-last-variant",
          name_vi: "San pham xoa bien the cuoi",
          name_en: "Delete last variant product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      variant =
        product_variant_fixture(product, %{
          variant_name_vi: "PLA Bac",
          variant_name_en: "Silver PLA"
        })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      html =
        view
        |> render_click("delete-product-variant", %{"id" => Integer.to_string(variant.id)})

      assert html =~ "Product variant removed successfully."
      assert html =~ "No variants"
      assert html =~ ~s(id="open-new-variant-dialog")
      assert html =~ ~r/>\s*New\s*<\/button>/
    end

    test "deleting the variant being edited closes the dialog safely", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "delete-editing-variant",
          name_vi: "San pham xoa khi dang sua",
          name_en: "Delete editing variant product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      variant =
        product_variant_fixture(product, %{
          variant_name_vi: "PLA Trang Sua",
          variant_name_en: "White Edit PLA"
        })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      _html =
        view
        |> element(~s(button[phx-click="open-edit-variant-dialog"][phx-value-id="#{variant.id}"]))
        |> render_click()

      html =
        view
        |> render_click("delete-product-variant", %{"id" => Integer.to_string(variant.id)})

      assert html =~ "Product variant removed successfully."
      refute html =~ "Edit product variant"
      assert html =~ "No variants"
    end

    test "deleting a foreign product variant is rejected safely", %{conn: conn} do
      product =
        product_fixture(
          collection_id: nil,
          slug: "safe-delete-variant",
          name_vi: "San pham an toan xoa",
          name_en: "Safe delete variant product",
          description_vi: "Mo ta",
          description_en: "Description"
        )

      local_variant =
        product_variant_fixture(product, %{
          variant_name_vi: "PLA Noi Bo",
          variant_name_en: "Local PLA"
        })

      foreign_variant =
        product_variant_fixture(product_fixture(collection_id: nil), %{
          variant_name_vi: "PLA Ngoai",
          variant_name_en: "Foreign PLA"
        })

      {:ok, view, _html} = live(conn, ~p"/admin/products/#{product.id}")

      html =
        view
        |> render_click("delete-product-variant", %{"id" => Integer.to_string(foreign_variant.id)})

      assert html =~ "Product variant not found."
      assert CaHeoShop.Products.get_product_variant!(foreign_variant.id).id == foreign_variant.id
      assert CaHeoShop.Products.get_product_variant!(local_variant.id).id == local_variant.id
    end
  end

  defp set_collection_assets_path(_context) do
    previous = System.get_env("CA_HEO_SHOP_ASSETS_PATH")

    path =
      Path.join(
        System.tmp_dir!(),
        "ca_heo_shop_test_assets_#{System.unique_integer([:positive])}"
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
