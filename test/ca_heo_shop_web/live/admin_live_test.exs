defmodule CaHeoShopWeb.AdminLiveTest do
  use CaHeoShopWeb.ConnCase

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

  test "renders collection management page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/collections")

    assert html =~ "Collections"
    assert html =~ "Create collection"
    refute html =~ "Search"
    assert html =~ "Description"
    assert html =~ "3D Printed Products"
    assert html =~ "custom-orders"
  end

  test "renders collection create, edit, and delete placeholders", %{conn: conn} do
    {:ok, _new, new_html} = live(conn, ~p"/admin/collections/new")

    assert new_html =~ "Create Collection"
    assert new_html =~ "Image Placeholder"
    assert new_html =~ "Product count"

    {:ok, _edit, edit_html} = live(conn, ~p"/admin/collections/3d-printed-products/edit")

    assert edit_html =~ "Edit Collection"
    assert edit_html =~ "3D Printed Products"
    assert edit_html =~ "Save Changes"

    {:ok, _delete, delete_html} = live(conn, ~p"/admin/collections/3d-printed-products/delete")

    assert delete_html =~ "Are you sure you want to delete this collection?"
    assert delete_html =~ "This is a mock action and will not delete real data."
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
