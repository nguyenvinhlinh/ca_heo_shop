defmodule CaHeoShopWeb.AdminLiveTest do
  use CaHeoShopWeb.ConnCase

  alias CaHeoShop.Collections

  import CaHeoShop.CollectionsFixtures
  import CaHeoShop.ProductsFixtures
  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

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

  test "renders product management page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/products")

    assert html =~ "Products"
    assert html =~ "Create product"
    refute html =~ "Search"
    assert html =~ "Cost"
    assert html =~ "Modular Desk Organizer"
  end

  test "renders product create, edit, and delete placeholders", %{conn: conn} do
    {:ok, _new, new_html} = live(conn, ~p"/admin/products/new")

    assert new_html =~ "Create Product"
    assert new_html =~ "Image Placeholder"
    assert new_html =~ "Cost"

    {:ok, _edit, edit_html} = live(conn, ~p"/admin/products/modular-desk-organizer/edit")

    assert edit_html =~ "Edit Product"
    assert edit_html =~ "Modular Desk Organizer"
    assert edit_html =~ "Save Changes"

    {:ok, _delete, delete_html} = live(conn, ~p"/admin/products/modular-desk-organizer/delete")

    assert delete_html =~ "Are you sure you want to delete this product?"
    assert delete_html =~ "This is a mock action and will not delete real data."
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
                 image_filename: "/images/storefront/category-kits.svg",
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

    assert {:ok, _view, html} =
             view
             |> form("#collection-form",
               collection: %{
                 name_vi: "Moi",
                 name_en: "New",
                 slug: "new-collection",
                 description_vi: "Cap nhat",
                 description_en: "Updated",
                 image_filename: "/images/storefront/category-prints.svg",
                 nav_display_order: ""
               }
             )
             |> render_submit()
             |> follow_redirect(conn, ~p"/admin/collections")

    assert html =~ "Collection updated"
    assert Collections.get_collection_by_slug!("new-collection").name_vi == "Moi"
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
end
