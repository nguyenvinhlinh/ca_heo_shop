defmodule CaHeoShopWeb.ProductLive do
  use CaHeoShopWeb, :live_view

  alias CaHeoShop.Collections
  alias CaHeoShop.Products
  alias CaHeoShop.Uploads
  alias CaHeoShopWeb.AdminLive

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Admin Products")
      |> assign(:product_filters, %{
        "collection" => "ALL",
        "page" => 1,
        "per_page" => 20,
        "q" => ""
      })
      |> assign_product_index(%{})

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, assign_product_index(socket, params)}
  end

  @impl true
  def handle_event("search_products", %{"q" => q}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/admin/products?#{product_filter_params(socket, %{"page" => 1, "q" => q})}"
     )}
  end

  def handle_event("change_product_collection", %{"collection" => collection}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         ~p"/admin/products?#{product_filter_params(socket, %{"collection" => collection, "page" => 1})}"
     )}
  end

  def handle_event("change_product_per_page", %{"per_page" => per_page}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         ~p"/admin/products?#{product_filter_params(socket, %{"page" => 1, "per_page" => per_page})}"
     )}
  end

  def handle_event("change_product_page", %{"page" => page}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/admin/products?#{product_filter_params(socket, %{"page" => page})}"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} variant={:admin}>
      <AdminLive.admin_shell current_scope={@current_scope} active={:products}>
        <.products_page
          products={@products}
          page={@page}
          per_page={@per_page}
          total_count={@total_count}
          total_pages={@total_pages}
          from={@from}
          to={@to}
          collection={@collection}
          q={@q}
          collection_options={@collection_options}
        />
      </AdminLive.admin_shell>
    </Layouts.app>
    """
  end

  attr :products, :list, required: true
  attr :page, :integer, required: true
  attr :per_page, :integer, required: true
  attr :total_count, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :from, :integer, required: true
  attr :to, :integer, required: true
  attr :collection, :string, required: true
  attr :q, :string, required: true
  attr :collection_options, :list, required: true

  def products_page(assigns) do
    ~H"""
    <AdminLive.page_header
      title="Products"
      section="Ecommerce"
      description="Browse the product catalog with real collection, image, and variant data."
    >
      <:actions>
        <.link navigate={~p"/admin/products/new"} class="btn btn-primary btn-sm">
          <.icon name="hero-plus" class="size-4" /> Create product
        </.link>
      </:actions>
    </AdminLive.page_header>

    <section class="card mt-6 bg-base-100 shadow-sm">
      <div class="card-body gap-5">
        <div class="grid gap-4 xl:grid-cols-[minmax(0,1fr)_14rem_10rem_9rem]">
          <form id="admin-products-search-form" phx-submit="search_products" class="min-w-0">
            <label class="form-control w-full">
              <span class="label-text text-sm font-medium">Search products</span>
              <div class="join">
                <input
                  type="text"
                  name="q"
                  value={@q}
                  class="input input-bordered join-item w-full min-w-0"
                />
                <button type="submit" class="btn btn-primary join-item ml-1">Search</button>
              </div>
            </label>
          </form>

          <form id="admin-products-collection-filter" phx-change="change_product_collection">
            <label class="form-control w-full">
              <span class="label-text text-sm font-medium">Collection</span>
              <select
                name="collection"
                class="select select-bordered w-full"
                value={@collection}
              >
                <option
                  :for={{label, value} <- @collection_options}
                  value={value}
                  selected={value == @collection}
                >
                  {label}
                </option>
              </select>
            </label>
          </form>

          <form id="admin-products-per-page" phx-change="change_product_per_page">
            <label class="form-control w-full">
              <span class="label-text text-sm font-medium">Rows per page</span>
              <select name="per_page" class="select select-bordered w-full" value={@per_page}>
                <option :for={value <- [20, 50, 100]} value={value} selected={value == @per_page}>
                  {value}
                </option>
              </select>
            </label>
          </form>

          <form id="admin-products-page-select" phx-change="change_product_page">
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
                <th class="w-64 min-w-64">Image</th>
                <th>Product</th>
                <th>Variants</th>
                <th class="text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr :if={@products == []}>
                <td colspan="4" class="py-12 text-center text-base-content/60">No products found.</td>
              </tr>
              <tr :for={product <- @products} class="hover:bg-base-200/40">
                <td class="w-64 min-w-64">
                  <%= if image_path = product_display_image_path(product) do %>
                    <img
                      src={image_path}
                      alt={product.name_en}
                      class="rounded-box object-cover"
                    />
                  <% else %>
                    <div class="flex items-center justify-center rounded-box bg-base-200 text-xs text-base-content/60">
                      No image
                    </div>
                  <% end %>
                </td>
                <td class="min-w-72">
                  <div class="space-y-1">
                  <p class="font-medium">[VN]{product.name_vi}</p>
                  <p class="font-medium">[EN]{product.name_en}</p>
                    <p class="text-xs text-base-content/60">/{product.slug}</p>
                    <p class="text-xs text-base-content/60">
                      Collection: {product_collection_label(product.collection)}
                    </p>
                    <p class="text-xs text-base-content/60">
                      Updated: {format_datetime(product.updated_at || product.inserted_at)}
                    </p>
                  </div>
                </td>
                <td class="min-w-72">
                  <div :if={product.product_variants == []} class="text-sm text-base-content/60">
                    No variants
                  </div>
                  <ul :if={product.product_variants != []} class="space-y-2">
                    <li
                      :for={variant <- product.product_variants}
                      class="rounded-box bg-base-200/60 px-3 py-2 text-sm"
                    >
                      <p class="font-medium">{variant.variant_name}</p>
                      <div class="mt-1 grid gap-1 text-xs text-base-content/70 md:grid-cols-3">
                        <span>Stock: {variant.stock_quantity}</span>
                        <span>Cost: {format_vnd(variant.production_cost)}</span>
                        <span>Price: {format_vnd(variant.selling_price)}</span>
                      </div>
                    </li>
                  </ul>
                </td>
                <td class="text-right">
                  <AdminLive.row_actions
                    view={~p"/products/#{product.slug}"}
                    edit={~p"/admin/products/#{product.slug}/edit"}
                    delete={~p"/admin/products/#{product.slug}/delete"}
                  />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="flex flex-col gap-4 border-t border-base-300 pt-4 md:flex-row md:items-center md:justify-between">
          <p class="text-sm text-base-content/60">
            Showing products {@from}-{@to} of {@total_count}
          </p>
          <div class="join self-end">
            <.link
              patch={products_path(assigns, @page - 1)}
              class={["btn join-item", @page <= 1 && "btn-disabled pointer-events-none"]}
            >
              <.icon name="hero-chevron-left" class="size-4" />
            </.link>
            <.link
              patch={products_path(assigns, @page + 1)}
              class={[
                "btn join-item",
                @page >= @total_pages && "btn-disabled pointer-events-none"
              ]}
            >
              <.icon name="hero-chevron-right" class="size-4" />
            </.link>
          </div>
        </div>
      </div>
    </section>
    """
  end

  defp assign_product_index(socket, params) do
    product_index = Products.list_admin_products(params)

    socket
    |> assign(:products, product_index.entries)
    |> assign(:page, product_index.page)
    |> assign(:per_page, product_index.per_page)
    |> assign(:total_count, product_index.total_count)
    |> assign(:total_pages, product_index.total_pages)
    |> assign(:from, product_index.from)
    |> assign(:to, product_index.to)
    |> assign(:collection, product_index.collection)
    |> assign(:q, product_index.q)
    |> assign(:collection_options, product_collection_options())
    |> assign(:product_filters, %{
      "collection" => product_index.collection,
      "page" => product_index.page,
      "per_page" => product_index.per_page,
      "q" => product_index.q
    })
  end

  defp product_collection_options do
    [
      {"All collections", "ALL"},
      {"No collection", "NULL"}
    ] ++
      Enum.map(Collections.list_filterable_collections(), fn collection ->
        {product_collection_label(collection), Integer.to_string(collection.id)}
      end)
  end

  defp product_filter_params(socket, overrides) do
    socket.assigns.product_filters
    |> Map.merge(stringify_filter_overrides(overrides))
  end

  defp stringify_filter_overrides(overrides) do
    for {key, value} <- overrides, into: %{} do
      {to_string(key), to_string(value)}
    end
  end

  defp products_path(assigns, page) do
    ~p"/admin/products?#{%{"collection" => assigns.collection, "page" => normalize_page_number(page, assigns.total_pages), "per_page" => assigns.per_page, "q" => assigns.q}}"
  end

  defp normalize_page_number(page, _total_pages) when page < 1, do: 1
  defp normalize_page_number(page, total_pages) when page > total_pages, do: total_pages
  defp normalize_page_number(page, _total_pages), do: page

  defp product_display_image_path(product) do
    case Enum.find(product.product_images, &(&1.display_order == 0)) do
      nil ->
        nil

      %{filename: filename, has_thumbnail: true} when is_binary(filename) ->
        Uploads.thumbnail_filename(filename)

      %{filename: filename} when is_binary(filename) ->
        filename
    end
  end

  defp product_collection_label(nil), do: "No collection"

  defp product_collection_label(collection) do
    cond do
      present?(collection.name_vi) -> collection.name_vi
      present?(collection.name_en) -> collection.name_en
      true -> "Collection ##{collection.id}"
    end
  end

  defp present?(value), do: is_binary(value) and String.trim(value) != ""

  defp format_vnd(value) when is_integer(value) do
    value
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/(.{3})/, "\\1,")
    |> String.reverse()
    |> String.trim_leading(",")
    |> Kernel.<>(" VND")
  end

  defp format_datetime(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end

  defp format_datetime(_value), do: "-"
end
