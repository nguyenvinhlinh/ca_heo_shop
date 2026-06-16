defmodule CaHeoShopWeb.Admin.CustomerLive do
  use CaHeoShopWeb, :live_view

  alias CaHeoShop.Accounts
  alias CaHeoShop.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:editing_customer, nil)
     |> assign(:show_customer_dialog, false)
     |> assign(:customer_form, to_form(Accounts.change_customer_profile(%User{role: "customer"})))}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, assign_customer_index(socket, params)}
  end

  @impl true
  def handle_event("search_customers", %{"q" => q}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/admin/customers?#{customer_filter_params(socket, %{"q" => q, "page" => 1})}"
     )}
  end

  def handle_event("change_customer_enabled", %{"enabled" => enabled}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         ~p"/admin/customers?#{customer_filter_params(socket, %{"enabled" => enabled, "page" => 1})}"
     )}
  end

  def handle_event("change_customer_page_size", %{"page_size" => page_size}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         ~p"/admin/customers?#{customer_filter_params(socket, %{"page_size" => page_size, "page" => 1})}"
     )}
  end

  def handle_event("change_customer_page", %{"page" => page}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/admin/customers?#{customer_filter_params(socket, %{"page" => page})}"
     )}
  end

  def handle_event("toggle_customer_enabled", %{"id" => id}, socket) do
    case Accounts.toggle_customer_enabled(id) do
      {:ok, customer} ->
        {:noreply,
         socket
         |> assign_customer_index(socket.assigns.customer_filters)
         |> put_flash(:info, toggle_customer_success_message(customer))}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Could not update customer status.")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not update customer status.")}
    end
  end

  def handle_event("edit_customer", %{"id" => id}, socket) do
    case Accounts.get_customer(id) do
      %User{} = customer ->
        {:noreply, open_customer_dialog(socket, customer)}

      nil ->
        {:noreply, put_flash(socket, :error, "Customer not found.")}
    end
  end

  def handle_event("validate_customer", %{"user" => params}, socket) do
    changeset =
      socket.assigns.editing_customer
      |> Accounts.change_customer_profile(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :customer_form, to_form(changeset))}
  end

  def handle_event("save_customer", %{"user" => params}, socket) do
    case Accounts.update_customer_profile(socket.assigns.editing_customer, params) do
      {:ok, _customer} ->
        {:noreply,
         socket
         |> close_customer_dialog()
         |> assign_customer_index(socket.assigns.customer_filters)
         |> put_flash(:info, "Customer updated successfully.")}

      {:error, :not_found} ->
        {:noreply,
         socket
         |> close_customer_dialog()
         |> put_flash(:error, "Customer not found.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:show_customer_dialog, true)
         |> assign(:customer_form, to_form(Map.put(changeset, :action, :validate)))}
    end
  end

  def handle_event("cancel_edit_customer", _params, socket) do
    {:noreply, close_customer_dialog(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} variant={:admin}>
      <CaHeoShopWeb.AdminLive.admin_shell current_scope={@current_scope} active={:customers}>
        <CaHeoShopWeb.AdminLive.page_header
          title="Customers"
          section="Ecommerce"
          description="Browse real customer accounts and their current access state."
        />

        <section class="card mt-6 bg-base-100 shadow-sm">
          <div class="card-body gap-5">
            <div class="grid gap-4 xl:grid-cols-[minmax(0,1fr)_12rem_10rem_9rem]">
              <form id="admin-customers-search-form" phx-submit="search_customers" class="min-w-0">
                <label class="form-control w-full">
                  <span class="label-text text-sm font-medium">Search customers</span>
                  <div class="join">
                    <input
                      type="text"
                      name="q"
                      value={@q}
                      placeholder="Search by full name or email"
                      class="input input-bordered join-item w-full min-w-0"
                    />
                    <button type="submit" class="btn btn-primary join-item">Search</button>
                  </div>
                </label>
              </form>

              <form id="admin-customers-enabled-filter" phx-change="change_customer_enabled">
                <label class="form-control w-full">
                  <span class="label-text text-sm font-medium">Enabled</span>
                  <select name="enabled" class="select select-bordered w-full" value={@enabled}>
                    <option
                      :for={{label, value} <- enabled_options()}
                      value={value}
                      selected={value == @enabled}
                    >
                      {label}
                    </option>
                  </select>
                </label>
              </form>

              <form id="admin-customers-page-size" phx-change="change_customer_page_size">
                <label class="form-control w-full">
                  <span class="label-text text-sm font-medium">Rows per page</span>
                  <select name="page_size" class="select select-bordered w-full" value={@page_size}>
                    <option :for={value <- [25, 50, 100]} value={value} selected={value == @page_size}>
                      {value}
                    </option>
                  </select>
                </label>
              </form>

              <form id="admin-customers-page-select" phx-change="change_customer_page">
                <label class="form-control w-full">
                  <span class="label-text text-sm font-medium">Page</span>
                  <select name="page" class="select select-bordered w-full" value={@page}>
                    <option
                      :for={page_number <- 1..max(@total_pages, 1)}
                      value={page_number}
                      selected={page_number == @page}
                    >
                      Page {page_number}
                    </option>
                  </select>
                </label>
              </form>
            </div>

            <div class="overflow-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone number</th>
                    <th>Enabled</th>
                    <th>Created at</th>
                    <th class="text-right">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr :if={@customers == []}>
                    <td colspan="6" class="py-12 text-center text-base-content/60">
                      No customers found.
                    </td>
                  </tr>
                  <tr
                    :for={customer <- @customers}
                    id={"customer-#{customer.id}"}
                    class="hover:bg-base-200/40"
                  >
                    <td class="min-w-56">
                      <div class="space-y-1">
                        <p class="font-medium">{display_name(customer)}</p>
                        <p class="text-xs text-base-content/60">
                          {display_customer_identity(customer)}
                        </p>
                      </div>
                    </td>
                    <td class="min-w-56">{display_email(customer)}</td>
                    <td>{display_phone_number(customer)}</td>
                    <td>
                      <input
                        type="checkbox"
                        class="toggle toggle-success"
                        phx-click="toggle_customer_enabled"
                        phx-value-id={customer.id}
                        aria-label={customer_toggle_button_label(customer)}
                        checked={customer.is_customer_enabled}
                      />
                    </td>
                    <td>{format_datetime(customer.inserted_at)}</td>
                    <td class="text-right">
                      <div class="flex justify-end gap-2">
                        <button type="button" class="btn btn-sm btn-secondary" aria-label="View order">
                          View order
                        </button>
                        <button
                          type="button"
                          class="btn btn-ghost btn-sm"
                          phx-click="edit_customer"
                          phx-value-id={customer.id}
                          aria-label="Edit customer"
                        >
                          <span class="hero-pencil-square size-4"></span>
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="flex flex-col gap-4 border-t border-base-300 pt-4 sm:flex-row sm:items-center sm:justify-between">
              <p class="text-sm text-base-content/60">{customer_summary(@from, @to, @total_count)}</p>

              <div class="join self-end">
                <.link
                  patch={customers_path(assigns, @page - 1)}
                  class={["btn btn-sm join-item", @page == 1 && "btn-disabled"]}
                  aria-label="Previous page"
                >
                  <.icon name="hero-chevron-left" class="size-4" />
                </.link>
                <span class="btn btn-sm join-item pointer-events-none">
                  Page {@page} / {max(@total_pages, 1)}
                </span>
                <.link
                  patch={customers_path(assigns, @page + 1)}
                  class={["btn btn-sm join-item", @page == @total_pages && "btn-disabled"]}
                  aria-label="Next page"
                >
                  <.icon name="hero-chevron-right" class="size-4" />
                </.link>
              </div>
            </div>
          </div>
        </section>

        <.customer_dialog
          show={@show_customer_dialog}
          customer={@editing_customer}
          form={@customer_form}
        />
      </CaHeoShopWeb.AdminLive.admin_shell>
    </Layouts.app>
    """
  end

  attr :show, :boolean, required: true
  attr :customer, :any, required: true
  attr :form, :any, required: true

  def customer_dialog(assigns) do
    ~H"""
    <div
      :if={@show}
      class="fixed inset-0 z-50 flex items-center justify-center bg-base-content/30 p-4 backdrop-blur-sm"
    >
      <div class="w-full max-w-xl rounded-box border border-base-300 bg-base-100 shadow-xl">
        <div class="p-6">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h2 class="text-lg font-semibold">Edit customer</h2>
              <p class="mt-1 text-sm text-base-content/70">
                Update the customer profile details used in admin and checkout flows.
              </p>
            </div>
            <button
              type="button"
              class="btn btn-ghost btn-sm btn-circle"
              aria-label="Close customer dialog"
              phx-click="cancel_edit_customer"
            >
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>

          <div :if={@customer} class="mt-4 rounded-box bg-base-200 p-4 text-sm text-base-content/70">
            <p class="font-medium text-base-content">{display_name(@customer)}</p>
            <p>{display_email(@customer)}</p>
          </div>

          <.form
            for={@form}
            id="customer-edit-form"
            phx-change="validate_customer"
            phx-submit="save_customer"
            class="mt-6 space-y-4"
          >
            <.input field={@form[:fullname]} label="Full name" />
            <.input field={@form[:phone_number]} label="Phone number" />

            <div class="flex justify-end gap-3 pt-2">
              <button type="button" class="btn btn-ghost" phx-click="cancel_edit_customer">
                Cancel
              </button>
              <button type="submit" class="btn btn-primary">
                Save
              </button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  defp assign_customer_index(socket, params) do
    customer_index = Accounts.list_customers(params)

    socket
    |> assign(:page_title, "Customers")
    |> assign(:customers, customer_index.entries)
    |> assign(:page, customer_index.page)
    |> assign(:page_size, customer_index.page_size)
    |> assign(:total_count, customer_index.total_count)
    |> assign(:total_pages, customer_index.total_pages)
    |> assign(:from, customer_index.from)
    |> assign(:to, customer_index.to)
    |> assign(:enabled, customer_index.enabled)
    |> assign(:q, customer_index.q)
    |> assign(:customer_filters, %{
      "enabled" => customer_index.enabled,
      "page" => customer_index.page,
      "page_size" => customer_index.page_size,
      "q" => customer_index.q
    })
  end

  defp customer_filter_params(socket, overrides) do
    socket.assigns.customer_filters
    |> Map.merge(stringify_filter_overrides(overrides))
  end

  defp stringify_filter_overrides(overrides) do
    for {key, value} <- overrides, into: %{} do
      {to_string(key), to_string(value)}
    end
  end

  defp customers_path(assigns, page) do
    ~p"/admin/customers?#{%{"enabled" => assigns.enabled, "page" => normalize_page_number(page, assigns.total_pages), "page_size" => assigns.page_size, "q" => assigns.q}}"
  end

  defp normalize_page_number(page, _total_pages) when page < 1, do: 1
  defp normalize_page_number(page, total_pages) when page > total_pages, do: total_pages
  defp normalize_page_number(page, _total_pages), do: page

  defp enabled_options do
    [{"All", "all"}, {"Enabled", "true"}, {"Disabled", "false"}]
  end

  defp display_name(%{fullname: fullname}) when is_binary(fullname) and fullname != "",
    do: fullname

  defp display_name(_customer), do: "-"

  defp display_email(%{email: email}) when is_binary(email) and email != "", do: email
  defp display_email(_customer), do: "-"

  defp display_phone_number(%{phone_number: phone_number})
       when is_binary(phone_number) and phone_number != "",
       do: phone_number

  defp display_phone_number(_customer), do: "-"

  defp display_customer_identity(%{username: username})
       when is_binary(username) and username != "",
       do: username

  defp display_customer_identity(%{email: email}) when is_binary(email) and email != "", do: email
  defp display_customer_identity(_customer), do: "customer"

  defp customer_toggle_button_label(%{is_customer_enabled: true}), do: "Disable"
  defp customer_toggle_button_label(_customer), do: "Enable"

  defp toggle_customer_success_message(%{is_customer_enabled: true}),
    do: "Customer enabled successfully."

  defp toggle_customer_success_message(_customer), do: "Customer disabled successfully."

  defp customer_summary(_from, _to, 0), do: "Showing 0 customers"

  defp customer_summary(from, to, total_count),
    do: "Showing #{from}-#{to} of #{total_count} customers"

  defp open_customer_dialog(socket, %User{} = customer) do
    socket
    |> assign(:editing_customer, customer)
    |> assign(:show_customer_dialog, true)
    |> assign(:customer_form, to_form(Accounts.change_customer_profile(customer)))
  end

  defp close_customer_dialog(socket) do
    socket
    |> assign(:editing_customer, nil)
    |> assign(:show_customer_dialog, false)
    |> assign(:customer_form, to_form(Accounts.change_customer_profile(%User{role: "customer"})))
  end

  defp format_datetime(nil), do: "-"

  defp format_datetime(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end
end
