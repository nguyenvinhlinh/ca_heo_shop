defmodule CaHeoShopWeb.AdminLive do
  use CaHeoShopWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:metrics, mock_metrics())
      |> assign(:products, mock_products())
      |> assign(:orders, mock_orders())
      |> assign(:customers, mock_customers())
      |> assign(:collections, mock_collections())
      |> assign(:settings, mock_settings())

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} variant={:admin}>
      <.admin_shell current_scope={@current_scope} active={@live_action}>
        <%= case @live_action do %>
          <% :dashboard -> %>
            <.dashboard_page metrics={@metrics} products={@products} orders={@orders} />
          <% :products -> %>
            <.products_page products={@products} />
          <% :orders -> %>
            <.orders_page orders={@orders} />
          <% :customers -> %>
            <.customers_page customers={@customers} />
          <% :collections -> %>
            <.collections_page collections={@collections} />
          <% :settings -> %>
            <.settings_page settings={@settings} />
        <% end %>
      </.admin_shell>
    </Layouts.app>
    """
  end

  attr :current_scope, :map, required: true
  attr :active, :atom, required: true
  slot :inner_block, required: true

  def admin_shell(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 text-base-content">
      <div class="drawer lg:drawer-open">
        <input id="admin-sidebar" type="checkbox" class="drawer-toggle" />
        <div class="drawer-content flex h-screen min-w-0 flex-col overflow-auto">
          <.admin_topbar current_scope={@current_scope} />
          <main id="layout-content" class="grow p-3 sm:p-4 md:p-6">
            {render_slot(@inner_block)}
          </main>
          <footer class="border-t border-base-300 px-6 py-4 text-xs text-base-content/60">
            Ca Heo DIY admin skeleton. Mock data only.
          </footer>
        </div>
        <aside class="drawer-side z-40">
          <label for="admin-sidebar" aria-label="Close sidebar" class="drawer-overlay"></label>
          <.admin_sidebar active={@active} />
        </aside>
      </div>
    </div>
    """
  end

  attr :active, :atom, required: true

  def admin_sidebar(assigns) do
    ~H"""
    <nav class="flex min-h-full w-64 flex-col border-r border-base-300 bg-base-100">
      <div class="flex min-h-16 items-center gap-3 border-b border-base-300 px-5">
        <img src={~p"/images/logo.svg"} width="34" alt="" />
        <div>
          <p class="font-semibold leading-tight">Ca Heo DIY</p>
          <p class="text-xs text-base-content/60">Admin</p>
        </div>
      </div>
      <ul class="menu grow gap-1 p-4">
        <li class="menu-title">Overview</li>
        <li>
          <.admin_nav_link href={~p"/admin"} active={@active == :dashboard} icon="hero-chart-bar">
            Dashboard
          </.admin_nav_link>
        </li>
        <li class="menu-title mt-3">Ecommerce</li>
        <li>
          <.admin_nav_link href={~p"/admin/products"} active={@active == :products} icon="hero-cube">
            Products
          </.admin_nav_link>
        </li>
        <li>
          <.admin_nav_link
            href={~p"/admin/orders"}
            active={@active == :orders}
            icon="hero-clipboard-document-list"
          >
            Orders
          </.admin_nav_link>
        </li>
        <li>
          <.admin_nav_link
            href={~p"/admin/customers"}
            active={@active == :customers}
            icon="hero-users"
          >
            Customers
          </.admin_nav_link>
        </li>
        <li>
          <.admin_nav_link
            href={~p"/admin/collections"}
            active={@active == :collections}
            icon="hero-tag"
          >
            Collections
          </.admin_nav_link>
        </li>
        <li class="menu-title mt-3">System</li>
        <li>
          <.admin_nav_link
            href={~p"/admin/settings"}
            active={@active == :settings}
            icon="hero-cog-6-tooth"
          >
            Settings
          </.admin_nav_link>
        </li>
      </ul>
      <div class="border-t border-base-300 p-4">
        <.link navigate={~p"/"} class="btn btn-ghost btn-sm w-full justify-start">
          <.icon name="hero-arrow-left" class="size-4" /> Storefront
        </.link>
      </div>
    </nav>
    """
  end

  attr :href, :string, required: true
  attr :active, :boolean, default: false
  attr :icon, :string, required: true
  slot :inner_block, required: true

  def admin_nav_link(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class={[
        "gap-3 rounded-box",
        @active && "active bg-primary text-primary-content"
      ]}
    >
      <.icon name={@icon} class="size-4" />
      <span>{render_slot(@inner_block)}</span>
    </.link>
    """
  end

  attr :current_scope, :map, required: true

  def admin_topbar(assigns) do
    ~H"""
    <header class="sticky top-0 z-30 flex min-h-16 items-center justify-between border-b border-base-300 bg-base-100/90 px-3 backdrop-blur sm:px-4 md:px-6">
      <div class="flex items-center gap-2">
        <label
          for="admin-sidebar"
          class="btn btn-square btn-ghost btn-sm lg:hidden"
          aria-label="Open sidebar"
        >
          <.icon name="hero-bars-3" class="size-5" />
        </label>
        <button class="btn btn-ghost btn-sm hidden gap-2 md:inline-flex" type="button">
          <.icon name="hero-magnifying-glass" class="size-4" /> Search
        </button>
      </div>
      <div class="flex items-center gap-2">
        <button class="btn btn-square btn-ghost btn-sm" type="button" aria-label="Notifications">
          <.icon name="hero-bell" class="size-5" />
        </button>
        <Layouts.theme_toggle />
        <div class="dropdown dropdown-end">
          <button type="button" tabindex="0" class="btn btn-ghost btn-sm max-w-56 gap-2">
            <.icon name="hero-user-circle" class="size-5" />
            <span class="hidden truncate sm:inline">{@current_scope.user.email}</span>
          </button>
          <ul
            tabindex="0"
            class="menu dropdown-content z-50 mt-3 w-56 rounded-box bg-base-100 p-2 shadow"
          >
            <li><.link navigate={~p"/users/settings"}>Account settings</.link></li>
            <li><.link href={~p"/users/log-out"} method="delete">Log out</.link></li>
          </ul>
        </div>
      </div>
    </header>
    """
  end

  attr :title, :string, required: true
  attr :section, :string, default: "Admin"
  attr :description, :string, default: nil
  slot :actions

  def page_header(assigns) do
    ~H"""
    <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
      <div>
        <div class="breadcrumbs hidden p-0 text-sm sm:inline-block">
          <ul>
            <li><.link navigate={~p"/admin"}>Ca Heo DIY</.link></li>
            <li>{@section}</li>
            <li class="opacity-80">{@title}</li>
          </ul>
        </div>
        <h1 class="mt-1 text-lg font-medium">{@title}</h1>
        <p :if={@description} class="mt-1 text-sm text-base-content/60">{@description}</p>
      </div>
      <div :if={@actions != []} class="flex flex-wrap gap-2">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  attr :metrics, :list, required: true
  attr :products, :list, required: true
  attr :orders, :list, required: true

  def dashboard_page(assigns) do
    ~H"""
    <.page_header
      title="Dashboard"
      section="Overview"
      description="Operational snapshot for the mock Ca Heo DIY store."
    >
      <:actions>
        <.link navigate={~p"/admin/products"} class="btn btn-primary btn-sm">
          <.icon name="hero-plus" class="size-4" /> New product
        </.link>
      </:actions>
    </.page_header>

    <section class="mt-6 grid gap-5 lg:grid-cols-2 xl:grid-cols-4">
      <.metric_card :for={metric <- @metrics} metric={metric} />
    </section>

    <section class="mt-6 grid grid-cols-1 gap-6 xl:grid-cols-12">
      <div class="card bg-base-100 shadow-sm xl:col-span-8">
        <div class="card-body">
          <div class="flex items-center justify-between">
            <div>
              <h2 class="card-title text-base">Sales Activity Placeholder</h2>
              <p class="text-sm text-base-content/60">
                Mock activity trend. No reporting data exists yet.
              </p>
            </div>
            <div class="tabs tabs-box">
              <button class="tab tab-active" type="button">Week</button>
              <button class="tab" type="button">Month</button>
            </div>
          </div>
          <div class="mt-6 grid h-64 grid-cols-12 items-end gap-2 rounded-box bg-base-200 p-4">
            <div
              :for={height <- [35, 50, 44, 72, 58, 86, 64, 78, 48, 92, 68, 74]}
              class="flex items-end"
            >
              <div class="w-full rounded-t bg-primary/70" style={"height: #{height}%"}></div>
            </div>
          </div>
        </div>
      </div>

      <div class="card bg-base-100 shadow-sm xl:col-span-4">
        <div class="card-body">
          <h2 class="card-title text-base">Quick Actions</h2>
          <div class="mt-3 grid gap-2">
            <.link navigate={~p"/admin/products"} class="btn btn-outline justify-start">
              <.icon name="hero-cube" class="size-4" /> Review products
            </.link>
            <.link navigate={~p"/admin/orders"} class="btn btn-outline justify-start">
              <.icon name="hero-clipboard-document-list" class="size-4" /> Review orders
            </.link>
            <.link navigate={~p"/admin/settings"} class="btn btn-outline justify-start">
              <.icon name="hero-cog-6-tooth" class="size-4" /> Store settings
            </.link>
          </div>
        </div>
      </div>

      <div class="card bg-base-100 shadow-sm xl:col-span-7">
        <div class="card-body p-0">
          <div class="flex items-center justify-between px-5 pt-5">
            <h2 class="font-medium">Recent Orders</h2>
            <.link navigate={~p"/admin/orders"} class="btn btn-ghost btn-sm">View all</.link>
          </div>
          <.orders_table orders={Enum.take(@orders, 4)} compact />
        </div>
      </div>

      <div class="card bg-base-100 shadow-sm xl:col-span-5">
        <div class="card-body p-0">
          <div class="flex items-center justify-between px-5 pt-5">
            <h2 class="font-medium">Product Overview</h2>
            <.link navigate={~p"/admin/products"} class="btn btn-ghost btn-sm">Manage</.link>
          </div>
          <div class="overflow-auto">
            <table class="table">
              <tbody>
                <tr :for={product <- Enum.take(@products, 4)} class="hover:bg-base-200/40">
                  <td>
                    <div class="font-medium">{product.name}</div>
                    <div class="text-xs text-base-content/60">{product.collection}</div>
                  </td>
                  <td><.status_badge status={product.status} /></td>
                  <td class="text-right">{product.stock}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </section>
    """
  end

  attr :metric, :map, required: true

  def metric_card(assigns) do
    ~H"""
    <div class="card bg-base-100 shadow-sm">
      <div class="card-body gap-3">
        <div class="flex items-center justify-between">
          <p class="text-sm text-base-content/60">{@metric.label}</p>
          <span class="rounded-box bg-base-200 p-2">
            <.icon name={@metric.icon} class="size-5" />
          </span>
        </div>
        <div class="text-2xl font-semibold">{@metric.value}</div>
        <p class="text-xs text-base-content/60">{@metric.note}</p>
      </div>
    </div>
    """
  end

  attr :products, :list, required: true

  def products_page(assigns) do
    ~H"""
    <.page_header title="Products" section="Ecommerce" description="Mock product management table.">
      <:actions>
        <button class="btn btn-primary btn-sm" type="button">
          <.icon name="hero-plus" class="size-4" /> Create product
        </button>
      </:actions>
    </.page_header>

    <section class="card mt-6 bg-base-100 shadow-sm">
      <div class="card-body p-0">
        <.table_toolbar search="Search products" filter="Collection" />
        <div class="overflow-auto">
          <table class="table">
            <thead>
              <tr>
                <th><input type="checkbox" class="checkbox checkbox-sm" /></th>
                <th>Product</th>
                <th>Collection</th>
                <th>Price</th>
                <th>Status</th>
                <th>Stock</th>
                <th>Updated At</th>
                <th class="text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={product <- @products} class="hover:bg-base-200/40">
                <td><input type="checkbox" class="checkbox checkbox-sm" /></td>
                <td>
                  <div class="flex items-center gap-3">
                    <img src={product.image} alt="" class="size-10 rounded-box object-cover" />
                    <div>
                      <p class="font-medium">{product.name}</p>
                      <p class="text-xs text-base-content/60">#{product.sku}</p>
                    </div>
                  </div>
                </td>
                <td>{product.collection}</td>
                <td>{product.price}</td>
                <td><.status_badge status={product.status} /></td>
                <td>{product.stock}</td>
                <td>{product.updated_at}</td>
                <td class="text-right">
                  <.row_actions />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <.pagination count={length(@products)} label="products" />
      </div>
    </section>
    """
  end

  attr :orders, :list, required: true

  def orders_page(assigns) do
    ~H"""
    <.page_header
      title="Orders"
      section="Ecommerce"
      description="Mock order queue for future processing workflows."
    />

    <section class="card mt-6 bg-base-100 shadow-sm">
      <div class="card-body p-0">
        <.table_toolbar search="Search orders" filter="Status" />
        <.orders_table orders={@orders} />
        <.pagination count={length(@orders)} label="orders" />
      </div>
    </section>
    """
  end

  attr :orders, :list, required: true
  attr :compact, :boolean, default: false

  def orders_table(assigns) do
    ~H"""
    <div class="overflow-auto">
      <table class="table">
        <thead>
          <tr>
            <th>Order Number</th>
            <th>Customer</th>
            <th>Status</th>
            <th>Total</th>
            <th>Created At</th>
            <th :if={!@compact} class="text-right">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={order <- @orders} class="hover:bg-base-200/40">
            <td class="font-medium">{order.number}</td>
            <td>
              <div>{order.customer}</div>
              <div class="text-xs text-base-content/60">{order.email}</div>
            </td>
            <td><.status_badge status={order.status} /></td>
            <td>{order.total}</td>
            <td>{order.created_at}</td>
            <td :if={!@compact} class="text-right"><.row_actions /></td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  attr :customers, :list, required: true

  def customers_page(assigns) do
    ~H"""
    <.page_header title="Customers" section="Ecommerce" description="Mock customer directory." />

    <section class="card mt-6 bg-base-100 shadow-sm">
      <div class="card-body p-0">
        <.table_toolbar search="Search customers" filter="Segment" />
        <div class="overflow-auto">
          <table class="table">
            <thead>
              <tr>
                <th>Customer</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Orders</th>
                <th>Last Order</th>
                <th class="text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={customer <- @customers} class="hover:bg-base-200/40">
                <td>
                  <div class="flex items-center gap-3">
                    <div class="avatar avatar-placeholder">
                      <div class="size-10 rounded-box bg-base-200 text-xs font-semibold">
                        {customer.initials}
                      </div>
                    </div>
                    <div>
                      <p class="font-medium">{customer.name}</p>
                      <p class="text-xs text-base-content/60">{customer.location}</p>
                    </div>
                  </div>
                </td>
                <td>{customer.email}</td>
                <td>{customer.phone}</td>
                <td>{customer.orders}</td>
                <td>{customer.last_order}</td>
                <td class="text-right"><.row_actions /></td>
              </tr>
            </tbody>
          </table>
        </div>
        <.pagination count={length(@customers)} label="customers" />
      </div>
    </section>
    """
  end

  attr :collections, :list, required: true

  def collections_page(assigns) do
    ~H"""
    <.page_header
      title="Collections"
      section="Ecommerce"
      description="Mock collection structure for catalog planning."
    >
      <:actions>
        <button class="btn btn-primary btn-sm" type="button">
          <.icon name="hero-plus" class="size-4" /> Create collection
        </button>
      </:actions>
    </.page_header>

    <section class="mt-6 grid gap-5 md:grid-cols-2 xl:grid-cols-4">
      <div :for={collection <- @collections} class="card bg-base-100 shadow-sm">
        <div class="card-body">
          <div class="flex items-start justify-between gap-3">
            <div>
              <h2 class="card-title text-base">{collection.name}</h2>
              <p class="text-sm text-base-content/60">/{collection.slug}</p>
            </div>
            <.status_badge status={collection.status} />
          </div>
          <div class="mt-4 flex items-center justify-between">
            <span class="text-sm text-base-content/60">Products</span>
            <span class="font-semibold">{collection.product_count}</span>
          </div>
          <div class="card-actions mt-4 justify-end">
            <.row_actions />
          </div>
        </div>
      </div>
    </section>
    """
  end

  attr :settings, :map, required: true

  def settings_page(assigns) do
    ~H"""
    <.page_header
      title="Settings"
      section="System"
      description="Static store preferences for admin workflow exploration."
    />

    <section class="mt-6 rounded-box bg-primary/10 p-6">
      <h2 class="text-xl font-semibold">Store configuration placeholder</h2>
      <p class="mt-2 max-w-3xl text-sm text-base-content/70">
        These controls are static and do not submit. They sketch future store, contact, shipping, and payment settings.
      </p>
    </section>

    <section class="card card-border mt-6 bg-base-100">
      <div class="card-body gap-8">
        <.settings_section title="Store information" description="Public-facing store identity.">
          <.input name="store_name" label="Store name" value={@settings.store_name} />
          <.input name="tagline" label="Tagline" value={@settings.tagline} />
        </.settings_section>

        <.settings_section
          title="Contact information"
          description="Customer support contact placeholders."
        >
          <.input name="email" type="email" label="Email" value={@settings.email} />
          <.input name="phone" label="Phone" value={@settings.phone} />
        </.settings_section>

        <.settings_section title="Shipping notes" description="Operational shipping copy placeholder.">
          <.input
            name="shipping_note"
            type="textarea"
            label="Shipping note"
            value={@settings.shipping_note}
          />
        </.settings_section>

        <.settings_section
          title="Payment notes"
          description="Static payment instructions placeholder."
        >
          <.input
            name="payment_note"
            type="textarea"
            label="Payment note"
            value={@settings.payment_note}
          />
        </.settings_section>

        <.settings_section
          title="General preferences"
          description="Simple toggles for future preferences."
        >
          <label class="flex cursor-pointer items-center justify-between rounded-box border border-base-300 p-4">
            <span>
              <span class="font-medium">Accept custom orders</span>
              <span class="block text-sm text-base-content/60">Static toggle only.</span>
            </span>
            <input type="checkbox" class="toggle toggle-primary" checked />
          </label>
          <label class="flex cursor-pointer items-center justify-between rounded-box border border-base-300 p-4">
            <span>
              <span class="font-medium">Low stock reminders</span>
              <span class="block text-sm text-base-content/60">Static toggle only.</span>
            </span>
            <input type="checkbox" class="toggle" checked />
          </label>
        </.settings_section>

        <div class="flex justify-end gap-2 border-t border-base-300 pt-6">
          <button class="btn btn-ghost" type="button">Cancel</button>
          <button class="btn btn-primary" type="button">Save placeholder</button>
        </div>
      </div>
    </section>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  slot :inner_block, required: true

  def settings_section(assigns) do
    ~H"""
    <section class="grid gap-4 lg:grid-cols-[16rem_1fr]">
      <div>
        <h2 class="font-semibold">{@title}</h2>
        <p class="mt-1 text-sm text-base-content/60">{@description}</p>
      </div>
      <div class="grid gap-4 lg:grid-cols-2">
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end

  attr :search, :string, required: true
  attr :filter, :string, required: true

  def table_toolbar(assigns) do
    ~H"""
    <div class="flex flex-col gap-3 px-5 pt-5 md:flex-row md:items-center md:justify-between">
      <div class="flex flex-col gap-3 sm:flex-row">
        <label class="input input-sm input-bordered flex w-full items-center gap-2 sm:w-72">
          <.icon name="hero-magnifying-glass" class="size-4 opacity-60" />
          <input type="search" class="grow" placeholder={@search} />
        </label>
        <select class="select select-bordered select-sm w-full sm:w-40">
          <option>{@filter}</option>
          <option>All</option>
          <option>Active</option>
        </select>
      </div>
      <div class="dropdown dropdown-end">
        <button tabindex="0" type="button" class="btn btn-outline btn-sm">
          More <.icon name="hero-chevron-down" class="size-4" />
        </button>
        <ul
          tabindex="0"
          class="menu dropdown-content z-20 mt-2 w-44 rounded-box bg-base-100 p-2 shadow"
        >
          <li><button type="button">Export mock CSV</button></li>
          <li><button type="button">Bulk action</button></li>
        </ul>
      </div>
    </div>
    """
  end

  attr :status, :string, required: true

  def status_badge(assigns) do
    ~H"""
    <span class={[
      "badge badge-sm badge-soft",
      status_class(@status)
    ]}>
      {@status}
    </span>
    """
  end

  def row_actions(assigns) do
    ~H"""
    <div class="join">
      <button class="btn btn-square btn-ghost btn-sm join-item" type="button" aria-label="View">
        <.icon name="hero-eye" class="size-4" />
      </button>
      <button class="btn btn-square btn-ghost btn-sm join-item" type="button" aria-label="Edit">
        <.icon name="hero-pencil-square" class="size-4" />
      </button>
      <button
        class="btn btn-square btn-error btn-outline btn-sm join-item border-transparent"
        type="button"
        aria-label="Delete"
      >
        <.icon name="hero-trash" class="size-4" />
      </button>
    </div>
    """
  end

  attr :count, :integer, required: true
  attr :label, :string, required: true

  def pagination(assigns) do
    ~H"""
    <div class="flex items-center justify-between border-t border-base-300 px-5 py-4">
      <select class="select select-xs w-20">
        <option>10</option>
        <option>25</option>
      </select>
      <p class="hidden text-sm text-base-content/60 lg:block">
        Showing 1 to {@count} of {@count} {@label}
      </p>
      <div class="join">
        <button class="btn btn-circle btn-xs join-item sm:btn-sm">1</button>
        <button class="btn btn-circle btn-xs btn-disabled join-item sm:btn-sm">2</button>
        <button class="btn btn-circle btn-xs btn-disabled join-item sm:btn-sm">
          <.icon name="hero-chevron-right" class="size-4" />
        </button>
      </div>
    </div>
    """
  end

  defp page_title(:dashboard), do: "Admin Dashboard"
  defp page_title(:products), do: "Admin Products"
  defp page_title(:orders), do: "Admin Orders"
  defp page_title(:customers), do: "Admin Customers"
  defp page_title(:collections), do: "Admin Collections"
  defp page_title(:settings), do: "Admin Settings"

  defp status_class("Active"), do: "badge-success"
  defp status_class("Available"), do: "badge-success"
  defp status_class("Paid"), do: "badge-success"
  defp status_class("Completed"), do: "badge-success"
  defp status_class("Pending"), do: "badge-warning"
  defp status_class("Draft"), do: "badge-info"
  defp status_class("Low stock"), do: "badge-warning"
  defp status_class("Paused"), do: "badge-error"
  defp status_class(_status), do: "badge-neutral"

  defp mock_metrics do
    [
      %{
        label: "Total Products",
        value: "24",
        note: "Includes draft mock products",
        icon: "hero-cube"
      },
      %{
        label: "Pending Orders",
        value: "7",
        note: "Awaiting owner review",
        icon: "hero-clock"
      },
      %{
        label: "Completed Orders",
        value: "18",
        note: "Mock month to date",
        icon: "hero-check-circle"
      },
      %{
        label: "Revenue Placeholder",
        value: "4.8M VND",
        note: "Static reporting preview",
        icon: "hero-banknotes"
      }
    ]
  end

  defp mock_products do
    [
      %{
        name: "Modular Desk Organizer",
        sku: "PRD-1001",
        collection: "3D Printed Products",
        price: "120.000 VND",
        status: "Available",
        stock: 12,
        updated_at: "2026-06-10",
        image: ~p"/images/storefront/product-organizer.svg"
      },
      %{
        name: "Starter Electronics Kit",
        sku: "KIT-2001",
        collection: "DIY Kits",
        price: "180.000 VND",
        status: "Low stock",
        stock: 3,
        updated_at: "2026-06-09",
        image: ~p"/images/storefront/product-kit.svg"
      },
      %{
        name: "Custom Plant Holder",
        sku: "HYD-3001",
        collection: "Hydroponics",
        price: "95.000 VND",
        status: "Available",
        stock: 18,
        updated_at: "2026-06-08",
        image: ~p"/images/storefront/product-holder.svg"
      },
      %{
        name: "Prototype Print Request",
        sku: "CUS-4001",
        collection: "Custom Orders",
        price: "Quote",
        status: "Draft",
        stock: 0,
        updated_at: "2026-06-07",
        image: ~p"/images/storefront/custom-order.svg"
      }
    ]
  end

  defp mock_orders do
    [
      %{
        number: "ORD-1024",
        customer: "Halo Nguyen",
        email: "halo@example.com",
        status: "Pending",
        total: "180.000 VND",
        created_at: "2026-06-11"
      },
      %{
        number: "ORD-1023",
        customer: "Linh Tran",
        email: "linh@example.com",
        status: "Paid",
        total: "215.000 VND",
        created_at: "2026-06-10"
      },
      %{
        number: "ORD-1022",
        customer: "Minh Pham",
        email: "minh@example.com",
        status: "Completed",
        total: "95.000 VND",
        created_at: "2026-06-09"
      },
      %{
        number: "ORD-1021",
        customer: "An Le",
        email: "an@example.com",
        status: "Draft",
        total: "Quote",
        created_at: "2026-06-08"
      }
    ]
  end

  defp mock_customers do
    [
      %{
        name: "Halo Nguyen",
        initials: "HN",
        email: "halo@example.com",
        phone: "090 000 0001",
        orders: 4,
        last_order: "2026-06-11",
        location: "Ho Chi Minh City"
      },
      %{
        name: "Linh Tran",
        initials: "LT",
        email: "linh@example.com",
        phone: "090 000 0002",
        orders: 2,
        last_order: "2026-06-10",
        location: "Da Nang"
      },
      %{
        name: "Minh Pham",
        initials: "MP",
        email: "minh@example.com",
        phone: "090 000 0003",
        orders: 1,
        last_order: "2026-06-09",
        location: "Hanoi"
      }
    ]
  end

  defp mock_collections do
    [
      %{
        name: "3D Printed Products",
        slug: "3d-printed-products",
        product_count: 9,
        status: "Active"
      },
      %{name: "DIY Kits", slug: "diy-kits", product_count: 5, status: "Active"},
      %{name: "Hydroponics", slug: "hydroponics", product_count: 4, status: "Active"},
      %{name: "Custom Orders", slug: "custom-orders", product_count: 2, status: "Paused"}
    ]
  end

  defp mock_settings do
    %{
      store_name: "Ca Heo DIY",
      tagline: "Small-batch DIY products and custom maker projects",
      email: "owner@caheo.example",
      phone: "090 000 0000",
      shipping_note: "Local shipping is confirmed manually after order review.",
      payment_note: "Bank transfer and COD are placeholder payment options."
    }
  end
end
