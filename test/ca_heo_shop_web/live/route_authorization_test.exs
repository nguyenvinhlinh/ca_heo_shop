defmodule CaHeoShopWeb.RouteAuthorizationTest do
  use CaHeoShopWeb.ConnCase

  import CaHeoShop.AccountsFixtures

  test "redirects guests from protected role routes", %{conn: conn} do
    for path <- [~p"/system", ~p"/admin", ~p"/products", ~p"/cart"] do
      redirected_conn = get(conn, path)

      assert redirected_to(redirected_conn) == ~p"/users/log-in"

      assert Phoenix.Flash.get(redirected_conn.assigns.flash, :error) ==
               "You must log in to access this page."
    end
  end

  test "allows system users into /system and redirects them away from other protected areas", %{
    conn: conn
  } do
    user = system_user_fixture()
    conn = log_in_user(conn, user)

    system_response = conn |> get(~p"/system") |> html_response(200)
    assert system_response =~ "System area placeholder."

    for path <- [~p"/admin", ~p"/products", ~p"/cart"] do
      redirected_conn = get(conn, path)

      assert redirected_to(redirected_conn) == ~p"/system"

      assert Phoenix.Flash.get(redirected_conn.assigns.flash, :error) ==
               "You are not allowed to access this page."
    end
  end

  test "allows admin users into /admin and redirects them away from other protected areas", %{
    conn: conn
  } do
    user = admin_user_fixture()
    conn = log_in_user(conn, user)

    admin_response = conn |> get(~p"/admin") |> html_response(200)
    assert admin_response =~ "Dashboard"

    for path <- [~p"/system", ~p"/products", ~p"/cart"] do
      redirected_conn = get(conn, path)

      assert redirected_to(redirected_conn) == ~p"/admin"

      assert Phoenix.Flash.get(redirected_conn.assigns.flash, :error) ==
               "You are not allowed to access this page."
    end
  end

  test "allows customer users into products and cart, and blocks admin/system routes", %{
    conn: conn
  } do
    user = customer_user_fixture()
    conn = log_in_user(conn, user)

    products_response = conn |> get(~p"/products") |> html_response(200)
    assert products_response =~ "Products"

    product_response = conn |> get(~p"/products/modular-desk-organizer") |> html_response(200)
    assert product_response =~ "Modular Desk Organizer"

    cart_response = conn |> get(~p"/cart") |> html_response(200)
    assert cart_response =~ "Order Summary"

    for path <- [~p"/system", ~p"/admin"] do
      redirected_conn = get(conn, path)

      assert redirected_to(redirected_conn) == ~p"/products"

      assert Phoenix.Flash.get(redirected_conn.assigns.flash, :error) ==
               "You are not allowed to access this page."
    end
  end
end
