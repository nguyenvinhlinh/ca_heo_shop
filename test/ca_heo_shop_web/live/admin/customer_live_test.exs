defmodule CaHeoShopWeb.Admin.CustomerLiveTest do
  use CaHeoShopWeb.ConnCase

  import CaHeoShop.AccountsFixtures
  import Phoenix.LiveViewTest

  setup :register_and_log_in_admin_user

  test "loads with the admin customer liveview namespace", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/admin/customers")

    assert view.module == CaHeoShopWeb.Admin.CustomerLive
    assert html =~ "Customers"
    assert html =~ "Search customers"
  end

  test "lists real customers and excludes non-customers", %{conn: conn} do
    enabled_customer =
      customer_user_fixture(%{
        fullname: "Enabled Customer",
        email: "enabled@example.com",
        phone_number: "090 111 2222"
      })

    disabled_customer =
      customer_user_fixture(%{
        fullname: "Disabled Customer",
        email: "disabled@example.com",
        phone_number: nil,
        is_customer_enabled: false
      })

    _admin = admin_user_fixture(%{fullname: "Admin User", email: nil})
    _system = system_user_fixture(%{fullname: "System User", email: nil})

    {:ok, _view, html} = live(conn, ~p"/admin/customers")

    assert html =~ "Enabled Customer"
    assert html =~ "Disabled Customer"
    assert html =~ "enabled@example.com"
    assert html =~ "090 111 2222"
    assert html =~ "Enabled"
    assert html =~ "Disabled"
    assert html =~ "View order"
    assert html =~ "Disable"
    assert html =~ "Enable"
    refute html =~ "Admin User"
    refute html =~ "System User"
    refute html =~ ">Show<"
    assert html =~ "Showing 1-2 of 2 customers"

    assert html =~ ~s(id="customer-#{enabled_customer.id}")
    assert html =~ ~s(id="customer-#{disabled_customer.id}")
  end

  test "searches by fullname and email", %{conn: conn} do
    _matching_customer =
      customer_user_fixture(%{
        fullname: "Nguyen Customer",
        email: "matching@example.com"
      })

    _other_customer =
      customer_user_fixture(%{
        fullname: "Other Customer",
        email: "other@example.com"
      })

    {:ok, view, _html} = live(conn, ~p"/admin/customers")

    render_submit(element(view, "#admin-customers-search-form"), %{"q" => "nguyen"})
    assert_patch(view, ~p"/admin/customers?enabled=all&page=1&page_size=25&q=nguyen")

    html = render(view)
    assert html =~ "Nguyen Customer"
    refute html =~ "Other Customer"

    render_submit(element(view, "#admin-customers-search-form"), %{"q" => "other@example.com"})

    assert_patch(
      view,
      ~p"/admin/customers?#{%{"enabled" => "all", "page" => 1, "page_size" => 25, "q" => "other@example.com"}}"
    )

    html = render(view)
    assert html =~ "Other Customer"
    refute html =~ "Nguyen Customer"
  end

  test "filters by enabled state", %{conn: conn} do
    _enabled_customer = customer_user_fixture(%{fullname: "Enabled Filter Customer"})

    _disabled_customer =
      customer_user_fixture(%{fullname: "Disabled Filter Customer", is_customer_enabled: false})

    {:ok, view, _html} = live(conn, ~p"/admin/customers")

    render_change(element(view, "#admin-customers-enabled-filter"), %{"enabled" => "true"})
    assert_patch(view, ~p"/admin/customers?enabled=true&page=1&page_size=25&q=")

    html = render(view)
    assert html =~ "Enabled Filter Customer"
    refute html =~ "Disabled Filter Customer"

    render_change(element(view, "#admin-customers-enabled-filter"), %{"enabled" => "false"})
    assert_patch(view, ~p"/admin/customers?enabled=false&page=1&page_size=25&q=")

    html = render(view)
    assert html =~ "Disabled Filter Customer"
    refute html =~ "Enabled Filter Customer"
  end

  test "supports pagination and page size selection", %{conn: conn} do
    for index <- 1..30 do
      customer_user_fixture(%{
        fullname: "Paged Customer #{index}",
        email: "paged-#{index}@example.com"
      })
    end

    {:ok, view, html} = live(conn, ~p"/admin/customers")

    assert html =~ "Showing 1-25 of 30 customers"

    render_change(element(view, "#admin-customers-page-select"), %{"page" => "2"})
    assert_patch(view, ~p"/admin/customers?enabled=all&page=2&page_size=25&q=")

    html = render(view)
    assert html =~ "Showing 26-30 of 30 customers"

    render_change(element(view, "#admin-customers-page-size"), %{"page_size" => "50"})
    assert_patch(view, ~p"/admin/customers?enabled=all&page=1&page_size=50&q=")

    html = render(view)
    assert html =~ "Showing 1-30 of 30 customers"

    render_change(element(view, "#admin-customers-page-size"), %{"page_size" => "100"})
    assert_patch(view, ~p"/admin/customers?enabled=all&page=1&page_size=100&q=")
  end

  test "normalizes invalid page and page size params", %{conn: conn} do
    customer_user_fixture(%{fullname: "Valid Customer"})

    {:ok, _view, html} = live(conn, ~p"/admin/customers?page=0&page_size=13&enabled=oops&q=")

    assert html =~ "Showing 1-1 of 1 customers"
    assert html =~ "Rows per page"
    assert html =~ "Page 1"
  end
end
