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
    assert html =~ "Recent Orders"
    assert html =~ "Product Overview"
    assert html =~ user.email
  end

  test "renders product management page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/products")

    assert html =~ "Products"
    assert html =~ "Create product"
    assert html =~ "Search products"
    assert html =~ "Modular Desk Organizer"
  end

  test "renders order management page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/orders")

    assert html =~ "Orders"
    assert html =~ "Search orders"
    assert html =~ "ORD-1024"
    assert html =~ "Pending"
  end

  test "renders customer management page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/customers")

    assert html =~ "Customers"
    assert html =~ "Search customers"
    assert html =~ "Halo Nguyen"
    assert html =~ "090 000 0001"
  end

  test "renders collection management page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/collections")

    assert html =~ "Collections"
    assert html =~ "Create collection"
    assert html =~ "3D Printed Products"
    assert html =~ "custom-orders"
  end

  test "renders settings page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/settings")

    assert html =~ "Settings"
    assert html =~ "Store information"
    assert html =~ "Contact information"
    assert html =~ "Shipping notes"
    assert html =~ "Payment notes"
    assert html =~ "General preferences"
  end
end
