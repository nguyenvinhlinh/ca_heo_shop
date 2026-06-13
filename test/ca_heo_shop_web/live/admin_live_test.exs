defmodule CaHeoShopWeb.AdminLiveTest do
  use CaHeoShopWeb.ConnCase

  alias CaHeoShop.Collections
  alias CaHeoShop.Uploads

  import CaHeoShop.CollectionsFixtures
  import CaHeoShop.ProductsFixtures
  import Phoenix.LiveViewTest

  setup :register_and_log_in_user
  setup :set_collection_assets_path

  test "redirects guests from admin dashboard" do
    conn = Phoenix.ConnTest.build_conn()

    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/admin")
  end

  test "renders admin dashboard", %{conn: conn, user: user} do
    {:ok, _view, html} = live(conn, ~p"/admin")

    assert html =~ "Dashboard"
    assert html =~ "Total Products"
    assert html =~ "Revenue Placeholder"
    assert html =~ "Profit Placeholder"
    assert html =~ "Inventory Value Placeholder"
    assert html =~ "Top Purchased Products"
    refute html =~ "Quick Actions"
    refute html =~ "Search"
    assert html =~ "Recent Orders"
    assert html =~ "Product Overview"
    assert html =~ user.email
  end

  test "renders product management page with real products and controls", %{conn: conn} do
    collection =
      collection_fixture(
        name_vi: "Bo suu tap in 3D",
        name_en: "Printed Collection",
        nav_display_order: 0
      )

    product =
      product_fixture(
        collection: collection,
        slug: "ban-phim",
        name_vi: "Gia do ban phim",
        name_en: "Keyboard Stand"
      )

    product_image_fixture(product,
      filename: "/images/storefront/keyboard-stand.jpg",
      display_order: 0,
      has_thumbnail: true
    )

    product_variant_fixture(product,
      variant_name_vi: "PLA Do",
      variant_name_en: "Red PLA",
      stock_quantity: 10,
      production_cost: 25_000,
      selling_price: 50_000
    )

    product_fixture(
      collection_id: nil,
      slug: "bo-oc-du-phong",
      name_vi: "Bo oc du phong",
      name_en: "Spare Fasteners"
    )

    {:ok, _view, html} = live(conn, ~p"/admin/products")

    assert html =~ "Products"
    assert html =~ "New product"
    assert html =~ "Search products"
    assert html =~ "Rows per page"
    assert html =~ "Page"
    assert html =~ "All collections"
    assert html =~ "No collection"
    assert html =~ "Gia do ban phim"
    assert html =~ "Keyboard Stand"
    assert html =~ "/ban-phim"
    assert html =~ "Bo suu tap in 3D"
    assert html =~ "PLA Do"
    assert html =~ "Red PLA"
    assert html =~ "Stock: 10"
    assert html =~ "Cost: 25,000 VND"
    assert html =~ "Price: 50,000 VND"
    assert html =~ "/images/storefront/keyboard-stand_500x500px.jpg"
    assert html =~ "Bo oc du phong"
    assert html =~ "No image"
    assert html =~ "No variants"
    assert html =~ "Showing products 1-2 of 2"
    assert html =~ "/admin/products/#{product.id}"
    refute html =~ "Export mock CSV"
    refute html =~ "Bulk action"
  end

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

    _first_variant =
      product_variant_fixture(product, %{
        variant_name_vi: "Bien the dau",
        variant_name_en: "First variant",
        display_order: 0,
        production_cost: 25_000,
        selling_price: 50_000,
        stock_quantity: 10,
        image_filename: "first-variant.jpg"
      })

    _second_variant =
      product_variant_fixture(product, %{
        variant_name_vi: "Bien the cung order",
        variant_name_en: "Second same order",
        display_order: 0,
        production_cost: 30_000,
        selling_price: 60_000,
        stock_quantity: 0,
        image_filename: nil
      })

    _later_variant =
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
    assert html =~ "ID ##{product.id}"
    assert html =~ "Kem cap nam cham"
    assert html =~ "Magnetic Cable Clip"
    assert html =~ "/magnetic-cable-clip"
    assert html =~ "Linh kien ban"
    assert html =~ "Keeps desk cables organized."
    assert html =~ "Giu day gon gang tren ban lam viec."
    assert html =~ "Image preview"
    assert html =~ "Product images"
    assert html =~ "Copy"
    assert html =~ "Delete"
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
    assert html =~ "New variant"
    assert html =~ ~s(phx-click="open-edit-variant-dialog")
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
      |> element(~s(button[phx-click="select-product-image"][phx-value-id="#{second_image.id}"]))
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

  test "reordering product images updates list order and keeps the selected image", %{conn: conn} do
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
      |> element(~s(button[phx-click="select-product-image"][phx-value-id="#{second_image.id}"]))
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
    assert html =~ "New variant"
    refute html =~ "New product variant"
    assert html =~ "No variants"
    assert html =~ ~s(class="btn btn-xs" disabled)
    assert html =~ ">Copy</button>"
    assert html =~ "—"
    assert html =~ ~s(class="btn btn-ghost btn-sm" disabled)
    assert html =~ ">View original</button>"
    refute html =~ "Edit"
    refute html =~ "Remove"
  end

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
      |> render_click("open-edit-variant-dialog", %{"id" => Integer.to_string(foreign_variant.id)})

    assert html =~ "Product variant not found."
    refute html =~ "Edit product variant"
  end

  test "renders new product page", %{conn: conn} do
    collection_fixture(name_vi: "Bo suu tap", name_en: "Collection", nav_display_order: 0)

    {:ok, _new, new_html} = live(conn, ~p"/admin/products/new")

    assert new_html =~ "New product"
    assert new_html =~ "Collection"
    assert new_html =~ "Slug"
    assert new_html =~ "Vietnamese name"
    assert new_html =~ "English name"
    assert new_html =~ "Vietnamese description"
    assert new_html =~ "English description"
    assert new_html =~ "Create product"
    assert new_html =~ "No collection"
    refute new_html =~ "stock_quantity"
    refute new_html =~ "production_cost"
    refute new_html =~ "selling_price"
    refute new_html =~ "collection-image-form"
  end

  test "creates a product from the new product form", %{conn: conn} do
    collection =
      collection_fixture(name_vi: "Bo suu tap", name_en: "Collection", nav_display_order: 0)

    {:ok, view, _html} = live(conn, ~p"/admin/products/new")

    assert {:ok, _view, html} =
             view
             |> form("#product-form",
               product: %{
                 collection_id: Integer.to_string(collection.id),
                 slug: "universal-phone-stand",
                 name_vi: "Gia do dien thoai",
                 name_en: "Universal Phone Stand",
                 description_vi: "Mo ta san pham",
                 description_en: "Product description"
               }
             )
             |> render_submit()
             |> follow_redirect(conn, ~p"/admin/products")

    assert html =~ "Product created successfully."
    assert html =~ "Gia do dien thoai"
  end

  test "validates the new product form and allows no collection", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/products/new")

    html =
      view
      |> form("#product-form",
        product: %{
          collection_id: "",
          slug: "invalid slug",
          name_vi: "",
          name_en: ""
        }
      )
      |> render_change()

    assert html =~ "can&#39;t be blank"
    assert html =~ "has invalid format"

    assert {:ok, _view, redirected_html} =
             view
             |> form("#product-form",
               product: %{
                 collection_id: "",
                 slug: "valid-phone-stand",
                 name_vi: "Gia do",
                 name_en: "Phone Stand",
                 description_vi: "",
                 description_en: ""
               }
             )
             |> render_submit()
             |> follow_redirect(conn, ~p"/admin/products")

    assert redirected_html =~ "Product created successfully."
  end

  test "renders product edit and delete placeholders", %{conn: conn} do
    {:ok, _edit, edit_html} = live(conn, ~p"/admin/products/modular-desk-organizer/edit")

    assert edit_html =~ "Edit Product"
    assert edit_html =~ "Modular Desk Organizer"
    assert edit_html =~ "Save Changes"

    {:ok, _delete, delete_html} = live(conn, ~p"/admin/products/modular-desk-organizer/delete")

    assert delete_html =~ "Are you sure you want to delete this product?"
    assert delete_html =~ "This is a mock action and will not delete real data."
  end

  test "filters products by collection and supports null collection filter", %{conn: conn} do
    visible_collection = collection_fixture(name_vi: "Visible collection", nav_display_order: 0)
    other_collection = collection_fixture(name_vi: "Other collection", nav_display_order: 1)

    visible_product =
      product_fixture(
        collection: visible_collection,
        slug: "visible-product",
        name_vi: "Visible product row"
      )

    _other_product =
      product_fixture(
        collection: other_collection,
        slug: "other-product",
        name_vi: "Other product row"
      )

    uncategorized_product =
      product_fixture(
        collection_id: nil,
        slug: "null-product",
        name_vi: "No collection product row"
      )

    {:ok, view, _html} = live(conn, ~p"/admin/products")

    render_change(element(view, "#admin-products-collection-filter"), %{"collection" => "NULL"})
    assert_patch(view, ~p"/admin/products?collection=NULL&page=1&per_page=20&q=")

    html = render(view)
    assert html =~ uncategorized_product.name_vi
    refute html =~ "/#{visible_product.slug}"

    render_change(element(view, "#admin-products-collection-filter"), %{
      "collection" => Integer.to_string(visible_collection.id)
    })

    assert_patch(
      view,
      ~p"/admin/products?collection=#{visible_collection.id}&page=1&per_page=20&q="
    )

    html = render(view)
    assert html =~ visible_product.name_vi
    refute html =~ "/#{uncategorized_product.slug}"
  end

  test "searches products by name", %{conn: conn} do
    matching =
      product_fixture(
        collection_id: nil,
        slug: "keyboard-stand",
        name_vi: "Gia do",
        name_en: "Keyboard Stand"
      )

    _other =
      product_fixture(
        collection_id: nil,
        slug: "cable-box",
        name_vi: "Hop cap",
        name_en: "Cable Box"
      )

    {:ok, view, _html} = live(conn, ~p"/admin/products")

    render_submit(element(view, "#admin-products-search-form"), %{"q" => "keyboard"})
    assert_patch(view, ~p"/admin/products?collection=ALL&page=1&per_page=20&q=keyboard")

    html = render(view)
    assert html =~ matching.name_en
    refute html =~ "Cable Box"
  end

  test "supports pagination and per_page params from the URL", %{conn: conn} do
    for index <- 1..21 do
      product_fixture(
        collection_id: nil,
        slug: "paged-product-#{index}",
        name_vi: "Paged #{index}",
        name_en: "Paged #{index}"
      )
    end

    {:ok, _paged_view, paged_html} = live(conn, ~p"/admin/products?page=2&per_page=20")

    assert paged_html =~ "Showing products 21-21 of 21"
    assert paged_html =~ "Paged 1"
  end

  test "renders order management page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/orders")

    assert html =~ "Orders"
    refute html =~ "Search"
    assert html =~ "ORD-1024"
    assert html =~ "Pending"
  end

  test "renders customer management page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/customers")

    assert html =~ "Customers"
    refute html =~ "Search"
    assert html =~ "Halo Nguyen"
    assert html =~ "090 000 0001"
  end

  test "renders collection management empty state", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/collections")

    assert html =~ "Collections"
    assert html =~ "Create collection"
    assert html =~ "No collections yet"
  end

  test "renders collection management page with real data", %{conn: conn} do
    collection_fixture(
      name_vi: "San pham in 3D",
      name_en: "3D Printed Products",
      slug: "3d-printed-products",
      description_vi: "Mo ta bo suu tap",
      nav_display_order: 0
    )

    collection_fixture(
      name_vi: "Dat hang tuy chinh",
      name_en: "Custom Orders",
      slug: "custom-orders",
      description_vi: "Nhan yeu cau rieng",
      nav_display_order: nil
    )

    {:ok, _view, html} = live(conn, ~p"/admin/collections")

    assert html =~ "San pham in 3D"
    assert html =~ "3D Printed Products"
    assert html =~ "/3d-printed-products"
    assert html =~ "Header #0"
    assert html =~ "Hidden"
  end

  test "uses thumbnail image on collection index when collection has_thumbnail is true", %{
    conn: conn
  } do
    collection =
      collection_fixture(
        slug: "thumb-preview",
        image_filename: "123_thumb-preview.jpg"
      )

    {:ok, _collection} = Collections.mark_collection_thumbnail_generated(collection)

    {:ok, _view, html} = live(conn, ~p"/admin/collections")

    assert html =~ "/collection_images/123_thumb-preview_500x500px.jpg"
    refute html =~ ~s(src="/collection_images/123_thumb-preview.jpg")
  end

  test "orders collections by nav_display_order then id on index", %{conn: conn} do
    first =
      collection_fixture(
        name_vi: "First visible",
        name_en: "First visible",
        slug: "first-visible",
        nav_display_order: 0
      )

    second =
      collection_fixture(
        name_vi: "Second visible",
        name_en: "Second visible",
        slug: "second-visible",
        nav_display_order: 0
      )

    hidden =
      collection_fixture(
        name_vi: "Hidden later",
        name_en: "Hidden later",
        slug: "hidden-later",
        nav_display_order: nil
      )

    {:ok, _view, html} = live(conn, ~p"/admin/collections")

    {first_pos, _} = :binary.match(html, first.name_vi)
    {second_pos, _} = :binary.match(html, second.name_vi)
    {hidden_pos, _} = :binary.match(html, hidden.name_vi)

    assert first_pos < second_pos
    assert second_pos < hidden_pos
  end

  test "renders collection create form and validates submission", %{conn: conn} do
    {:ok, view, new_html} = live(conn, ~p"/admin/collections/new")

    assert new_html =~ "Create Collection"
    assert new_html =~ "Vietnamese name"
    refute new_html =~ "collection-image-form"
    refute new_html =~ "Image filename"
    refute new_html =~ "Product count"
    refute new_html =~ "Status"

    html =
      view
      |> form("#collection-form", collection: %{name_vi: "", name_en: "", slug: ""})
      |> render_change()

    assert html =~ "can&#39;t be blank"
  end

  test "creates a collection from the admin form", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/collections/new")

    assert {:ok, _view, html} =
             view
             |> form("#collection-form",
               collection: %{
                 name_vi: "Bo kit DIY",
                 name_en: "DIY Kits",
                 slug: "diy-kits",
                 description_vi: "Mo ta",
                 description_en: "Description",
                 nav_display_order: "1"
               }
             )
             |> render_submit()
             |> follow_redirect(conn, ~p"/admin/collections")

    assert html =~ "Collection created"
    assert Collections.get_collection_by_slug!("diy-kits").name_vi == "Bo kit DIY"
  end

  test "renders collection edit form and updates the collection", %{conn: conn} do
    collection =
      collection_fixture(
        name_vi: "Cu",
        name_en: "Old",
        slug: "old-collection",
        nav_display_order: 0
      )

    {:ok, view, edit_html} = live(conn, ~p"/admin/collections/#{collection.slug}/edit")

    assert edit_html =~ "Edit Collection"
    assert edit_html =~ "Cu"
    assert edit_html =~ "collection-image-form"

    assert {:ok, _view, html} =
             view
             |> form("#collection-form",
               collection: %{
                 name_vi: "Moi",
                 name_en: "New",
                 slug: "new-collection",
                 description_vi: "Cap nhat",
                 description_en: "Updated",
                 nav_display_order: ""
               }
             )
             |> render_submit()
             |> follow_redirect(conn, ~p"/admin/collections")

    assert html =~ "Collection updated"
    assert Collections.get_collection_by_slug!("new-collection").name_vi == "Moi"
  end

  test "uses thumbnail image on collection edit preview when collection has_thumbnail is true", %{
    conn: conn
  } do
    collection =
      collection_fixture(
        slug: "edit-thumb-preview",
        image_filename: "999_edit-thumb-preview.jpg"
      )

    {:ok, _collection} = Collections.mark_collection_thumbnail_generated(collection)

    {:ok, _view, html} = live(conn, ~p"/admin/collections/#{collection.slug}/edit")

    assert html =~ "/collection_images/999_edit-thumb-preview_500x500px.jpg"
    refute html =~ ~s(src="/collection_images/999_edit-thumb-preview.jpg")
  end

  test "uploads a collection image from the edit page", %{conn: conn} do
    collection = collection_fixture(image_filename: nil)

    {:ok, view, _html} = live(conn, ~p"/admin/collections/#{collection.slug}/edit")

    upload =
      file_input(view, "#collection-image-form", :collection_image, [
        %{name: "collection.jpeg", content: "fake-jpeg", type: "image/jpeg"}
      ])

    assert render_upload(upload, "collection.jpeg") =~ "100%"

    html =
      view
      |> form("#collection-image-form", %{})
      |> render_submit()

    assert html =~ "Collection image uploaded"

    updated_collection = Collections.get_collection!(collection.id)

    assert updated_collection.has_thumbnail == false
    assert updated_collection.image_filename =~ ~r/^#{collection.id}_.+\.jpg$/

    assert Uploads.public_collection_image_path(updated_collection.image_filename) =~
             "/collection_images/"

    assert {:ok, image_path} = Uploads.collection_image_path(updated_collection.image_filename)
    assert File.exists?(image_path)
  end

  test "deletes a collection image from the edit page", %{conn: conn} do
    collection = collection_fixture(image_filename: nil)

    {:ok, uploaded_collection} =
      Collections.replace_collection_image(collection, %{
        path: write_temp_upload!("collection.jpg", "jpg-data"),
        client_name: "collection.jpg"
      })

    {:ok, image_path} = Uploads.collection_image_path(uploaded_collection.image_filename)

    {:ok, thumbnail_path} =
      uploaded_collection.image_filename
      |> Uploads.thumbnail_filename()
      |> Uploads.collection_image_path()

    File.write!(thumbnail_path, "thumb-data")

    {:ok, view, html} = live(conn, ~p"/admin/collections/#{uploaded_collection.slug}/edit")

    assert html =~ "Delete image"

    html =
      view
      |> element("#delete-collection-image-button")
      |> render_click()

    assert html =~ "Collection image deleted successfully."
    refute html =~ "Delete image"

    updated_collection = Collections.get_collection!(uploaded_collection.id)
    assert updated_collection.image_filename == nil
    assert updated_collection.has_thumbnail == nil
    refute File.exists?(image_path)
    refute File.exists?(thumbnail_path)
  end

  test "rejects unsupported collection image uploads", %{conn: conn} do
    collection = collection_fixture(image_filename: nil)

    {:ok, view, _html} = live(conn, ~p"/admin/collections/#{collection.slug}/edit")

    upload =
      file_input(view, "#collection-image-form", :collection_image, [
        %{name: "collection.gif", content: "gif-data", type: "image/gif"}
      ])

    assert {:error, [[_ref, :not_accepted]]} = render_upload(upload, "collection.gif")
  end

  test "opens collection delete dialog from index and deletes the collection", %{conn: conn} do
    _collection = collection_fixture(slug: "delete-me", name_vi: "Xoa di", name_en: "Delete me")

    {:ok, view, index_html} = live(conn, ~p"/admin/collections")

    assert index_html =~ "Xoa di"

    dialog_html =
      view
      |> element(~s(button[phx-value-slug="delete-me"]))
      |> render_click()

    assert dialog_html =~ "Delete collection?"
    assert dialog_html =~ "Delete me"

    assert {:ok, _view, html} =
             view
             |> element("button", "Delete collection")
             |> render_click()
             |> follow_redirect(conn, ~p"/admin/collections")

    assert html =~ "Collection deleted"
    assert_raise Ecto.NoResultsError, fn -> Collections.get_collection_by_slug!("delete-me") end
  end

  test "keeps the collection when dialog delete is blocked by products", %{conn: conn} do
    collection = collection_fixture(slug: "cannot-delete", name_vi: "Dang dung", name_en: "Used")
    _product = product_fixture(collection: collection)

    {:ok, view, _index_html} = live(conn, ~p"/admin/collections")

    _dialog_html =
      view
      |> element(~s(button[phx-value-slug="cannot-delete"]))
      |> render_click()

    html =
      view
      |> element("button", "Delete collection")
      |> render_click()

    assert html =~ "Cannot delete this collection while products still belong to it."
    assert Collections.get_collection_by_slug!("cannot-delete").id == collection.id
  end

  test "renders settings page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/settings")

    assert html =~ "Settings"
    refute html =~ "Search"
    refute html =~ "Store information"
    refute html =~ "Public-facing store identity"
    refute html =~ "Store name"
    refute html =~ "Tagline"
    assert html =~ "Contact information"
    assert html =~ "Shipping notes"
    assert html =~ "Payment notes"
    refute html =~ "General preferences"
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
