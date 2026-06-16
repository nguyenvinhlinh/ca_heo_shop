defmodule CaHeoShopWeb.StorefrontLiveTest do
  use CaHeoShopWeb.ConnCase

  import CaHeoShop.AccountsFixtures
  import Phoenix.LiveViewTest

  test "renders the storefront homepage", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "Custom-made DIY products"
    assert html =~ "Featured Products"
    assert html =~ "Products"
    assert html =~ "Collections"
    assert html =~ "Cart"
    assert html =~ "Halo Nguyen"
    refute html =~ ~s|navigate="/account"|
  end

  test "renders product listing page", %{conn: conn} do
    conn = log_in_user(conn, customer_user_fixture())
    {:ok, _view, html} = live(conn, ~p"/products")

    assert html =~ "Products"
    assert html =~ "Search products"
    assert html =~ "Filter Area"
  end

  test "renders product detail page", %{conn: conn} do
    conn = log_in_user(conn, customer_user_fixture())
    {:ok, view, html} = live(conn, ~p"/products/modular-desk-organizer")

    assert html =~ "Modular Desk Organizer"
    assert has_element?(view, "#add-to-cart-button")
  end

  test "renders cart, checkout, and account pages", %{conn: conn} do
    conn = log_in_user(conn, customer_user_fixture())
    {:ok, _cart, cart_html} = live(conn, ~p"/cart")
    assert cart_html =~ "Order Summary"

    {:ok, checkout, checkout_html} = live(conn, ~p"/checkout")
    assert checkout_html =~ "Payment method"
    assert has_element?(checkout, "#checkout-form")

    {:ok, _account, account_html} = live(conn, ~p"/account")
    assert account_html =~ "Recent Orders Placeholder"
  end

  test "renders collection routes with mock collection data", %{conn: conn} do
    {:ok, _collections, collections_html} = live(conn, ~p"/collections")

    assert collections_html =~ "Collections"
    assert collections_html =~ "3D Printed Products"
    assert collections_html =~ "Home Accessories"

    {:ok, _collection, collection_html} = live(conn, ~p"/collections/diy-kits")

    assert collection_html =~ "DIY Kits"
    assert collection_html =~ "Starter Electronics Kit"
  end

  test "renders account dropdown destinations as mock pages", %{conn: conn} do
    {:ok, _orders, orders_html} = live(conn, ~p"/orders")

    assert orders_html =~ "Orders"
    assert orders_html =~ "MOCK-1001"

    {:ok, _settings, settings_html} = live(conn, ~p"/account/settings")

    assert settings_html =~ "Account Settings"
    assert settings_html =~ "Full Name"
    assert settings_html =~ "Password"
    assert settings_html =~ "Address"
  end
end
