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
    assert html =~ "hero-pencil-square size-4"
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

  test "opens edit dialog with prefilled customer info", %{conn: conn} do
    customer =
      customer_user_fixture(%{
        fullname: "Editable Customer",
        email: "editable@example.com",
        phone_number: "0900 111 222"
      })

    {:ok, view, _html} = live(conn, ~p"/admin/customers")

    render_click(element(view, ~s(#customer-#{customer.id} [aria-label="Edit customer"])))

    assert has_element?(view, "#customer-edit-form")
    assert has_element?(view, ~s(input[name="user[fullname]"][value="Editable Customer"]))
    assert has_element?(view, ~s(input[name="user[phone_number]"][value="0900 111 222"]))
    assert render(view) =~ "editable@example.com"
  end

  test "saves edited customer info and preserves current index filters", %{conn: conn} do
    target_customer =
      customer_user_fixture(%{
        fullname: "Paged Customer 1",
        email: "paged-1@example.com",
        phone_number: "0900 111 222"
      })

    for index <- 2..30 do
      customer_user_fixture(%{
        fullname: "Paged Customer #{index}",
        email: "paged-#{index}@example.com"
      })
    end

    {:ok, view, _html} = live(conn, ~p"/admin/customers?page=2")

    assert render(view) =~ "Showing 26-30 of 30 customers"

    render_click(element(view, ~s(#customer-#{target_customer.id} [aria-label="Edit customer"])))

    render_submit(element(view, "#customer-edit-form"), %{
      "user" => %{
        "fullname" => "Updated Paged Customer",
        "phone_number" => "0988 777 666"
      }
    })

    html = render(view)
    assert html =~ "Customer updated successfully."
    assert html =~ "Updated Paged Customer"
    assert html =~ "0988 777 666"
    assert html =~ "Showing 26-30 of 30 customers"

    updated_customer = CaHeoShop.Accounts.get_user!(target_customer.id)
    assert updated_customer.fullname == "Updated Paged Customer"
    assert updated_customer.phone_number == "0988 777 666"
  end

  test "shows validation errors and keeps entered values on invalid save", %{conn: conn} do
    customer =
      customer_user_fixture(%{fullname: "Validation Customer", phone_number: "0900 111 222"})

    too_long_name = String.duplicate("a", 256)
    too_long_phone = String.duplicate("1", 51)

    {:ok, view, _html} = live(conn, ~p"/admin/customers")

    render_click(element(view, ~s(#customer-#{customer.id} [aria-label="Edit customer"])))

    html =
      render_submit(element(view, "#customer-edit-form"), %{
        "user" => %{
          "fullname" => too_long_name,
          "phone_number" => too_long_phone
        }
      })

    assert html =~ "should be at most 255 character(s)"
    assert html =~ "should be at most 50 character(s)"
    assert has_element?(view, "#customer-edit-form")
    assert html =~ too_long_phone

    unchanged_customer = CaHeoShop.Accounts.get_user!(customer.id)
    assert unchanged_customer.fullname == "Validation Customer"
    assert unchanged_customer.phone_number == "0900 111 222"
  end

  test "cancel closes the dialog without saving and preserves filters", %{conn: conn} do
    customer =
      customer_user_fixture(%{
        fullname: "Cancelable Customer",
        email: "cancel@example.com",
        phone_number: "0900 111 222"
      })

    {:ok, view, _html} = live(conn, ~p"/admin/customers?enabled=all&page=1&page_size=25&q=cancel")

    render_click(element(view, ~s(#customer-#{customer.id} [aria-label="Edit customer"])))
    assert has_element?(view, "#customer-edit-form")

    render_click(element(view, ~s(#customer-edit-form button[type="button"])))

    refute has_element?(view, "#customer-edit-form")
    assert render(view) =~ "Showing 1-1 of 1 customers"

    unchanged_customer = CaHeoShop.Accounts.get_user!(customer.id)
    assert unchanged_customer.fullname == "Cancelable Customer"
    assert unchanged_customer.phone_number == "0900 111 222"
  end

  test "rejects editing non-customer users", %{conn: conn} do
    admin_user = admin_user_fixture(%{fullname: "Admin User"})

    {:ok, view, _html} = live(conn, ~p"/admin/customers")

    render_click(view, "edit_customer", %{"id" => Integer.to_string(admin_user.id)})

    assert render(view) =~ "Customer not found."
    refute has_element?(view, "#customer-edit-form")
  end
end
