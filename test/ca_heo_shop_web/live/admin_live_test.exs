defmodule CaHeoShopWeb.AdminLiveTest do
  use CaHeoShopWeb.ConnCase

  alias CaHeoShop.Collections
  alias CaHeoShop.Uploads

  import CaHeoShop.CollectionsFixtures
  import CaHeoShop.ProductsFixtures
  import Phoenix.LiveViewTest

  setup :register_and_log_in_admin_user
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
    assert html =~ user.username
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
    assert html =~ ~s(id="delete-product-#{product.id}")
    assert html =~ ~s(phx-click="delete-product")
    assert html =~ ~s(phx-value-id="#{product.id}")
    assert html =~ ~s(data-confirm="Delete this product and all related variants and images?")
    refute html =~ "Export mock CSV"
    refute html =~ "Bulk action"
  end

  test "deletes a product from the index and updates the summary", %{conn: conn} do
    removed_product =
      product_fixture(
        collection_id: nil,
        slug: "removed-product",
        name_vi: "Removed product",
        name_en: "Removed product"
      )

    kept_product =
      product_fixture(
        collection_id: nil,
        slug: "kept-product",
        name_vi: "Kept product",
        name_en: "Kept product"
      )

    {:ok, view, _html} = live(conn, ~p"/admin/products")

    html =
      view
      |> render_click("delete-product", %{"id" => Integer.to_string(removed_product.id)})

    assert html =~ "Product deleted successfully."
    refute html =~ "Removed product"
    assert html =~ "Kept product"
    assert html =~ "Showing products 1-1 of 1"

    assert_raise Ecto.NoResultsError, fn ->
      CaHeoShop.Products.get_product!(removed_product.id)
    end

    assert CaHeoShop.Products.get_product!(kept_product.id).id == kept_product.id
  end

  test "deletes a product with related variants and images from the index", %{conn: conn} do
    product =
      product_fixture(
        collection_id: nil,
        slug: "delete-with-deps",
        name_vi: "Delete with deps",
        name_en: "Delete with deps"
      )

    variant = product_variant_fixture(product, variant_name_vi: "PLA", variant_name_en: "PLA")
    upload_path = write_temp_upload!("delete-index-product.jpg", "jpg-data")

    assert {:ok, product_image} =
             CaHeoShop.Products.add_product_image_upload(product, %{
               path: upload_path,
               client_name: "delete-index-product.jpg"
             })

    {:ok, stored_path} = Uploads.product_image_path(product_image.filename)

    {:ok, thumbnail_path} =
      Uploads.product_image_path(Uploads.thumbnail_filename(product_image.filename))

    File.write!(thumbnail_path, "thumb-data")

    {:ok, view, _html} = live(conn, ~p"/admin/products")

    html =
      view
      |> render_click("delete-product", %{"id" => Integer.to_string(product.id)})

    assert html =~ "Product deleted successfully."
    refute html =~ "Delete with deps"
    refute File.exists?(stored_path)
    refute File.exists?(thumbnail_path)

    assert_raise Ecto.NoResultsError, fn ->
      CaHeoShop.Products.get_product_variant!(variant.id)
    end

    assert_raise Ecto.NoResultsError, fn ->
      CaHeoShop.Products.get_product_image!(product_image.id)
    end
  end

  test "deleting the last product on a page adjusts to the previous valid page", %{conn: conn} do
    for index <- 1..21 do
      product_fixture(
        collection_id: nil,
        slug: "delete-paged-product-#{index}",
        name_vi: "Delete paged #{index}",
        name_en: "Delete paged #{index}"
      )
    end

    last_product =
      CaHeoShop.Products.list_admin_products(%{"page" => 2, "per_page" => 20}).entries
      |> List.first()

    {:ok, view, _html} = live(conn, ~p"/admin/products?page=2&per_page=20")

    render_click(view, "delete-product", %{"id" => Integer.to_string(last_product.id)})

    assert_patch(view, ~p"/admin/products?collection=ALL&page=1&per_page=20&q=")

    html = render(view)
    assert html =~ "Product deleted successfully."
    assert html =~ "Showing products 1-20 of 20"
  end

  test "deleting the only product shows the empty state", %{conn: conn} do
    product =
      product_fixture(
        collection_id: nil,
        slug: "only-product",
        name_vi: "Only product",
        name_en: "Only product"
      )

    {:ok, view, _html} = live(conn, ~p"/admin/products")

    html =
      view
      |> render_click("delete-product", %{"id" => Integer.to_string(product.id)})

    assert html =~ "Product deleted successfully."
    assert html =~ "No products found."
    assert html =~ "Showing products 0-0 of 0"
  end

  test "deleting a product preserves active filters", %{conn: conn} do
    collection = collection_fixture(name_vi: "Delete filter", nav_display_order: 0)

    removed_product =
      product_fixture(
        collection: collection,
        slug: "filter-phone-removed",
        name_vi: "Filter removed",
        name_en: "Phone removed"
      )

    kept_product =
      product_fixture(
        collection: collection,
        slug: "filter-phone-kept",
        name_vi: "Filter kept",
        name_en: "Phone kept"
      )

    _other_product =
      product_fixture(
        collection_id: nil,
        slug: "outside-filter",
        name_vi: "Outside filter",
        name_en: "Cable box"
      )

    {:ok, view, _html} =
      live(conn, ~p"/admin/products?collection=#{collection.id}&page=1&per_page=20&q=phone")

    html =
      view
      |> render_click("delete-product", %{"id" => Integer.to_string(removed_product.id)})

    assert html =~ "Product deleted successfully."
    assert html =~ kept_product.name_en
    refute html =~ "Outside filter"

    search_html = view |> element("#admin-products-search-form") |> render()
    filter_html = view |> element("#admin-products-collection-filter") |> render()

    assert search_html =~ ~s(value="phone")
    assert filter_html =~ ~s(option value="#{collection.id}" selected="")
  end

  test "deleting a missing product from the index shows an error", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/products")

    html =
      view
      |> render_click("delete-product", %{"id" => "999999"})

    assert html =~ "Product not found."
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

  test "renders product delete placeholder", %{conn: conn} do
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
