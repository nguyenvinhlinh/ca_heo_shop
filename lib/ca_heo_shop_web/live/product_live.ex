defmodule CaHeoShopWeb.ProductLive do
  use CaHeoShopWeb, :live_view

  alias CaHeoShop.Collections
  alias CaHeoShop.Products.Product
  alias CaHeoShop.Products.ProductVariant
  alias CaHeoShop.Products
  alias CaHeoShop.Uploads
  alias CaHeoShopWeb.AdminLive

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Products")
      |> assign(:selected_product, %Product{})
      |> assign(:selected_product_image, nil)
      |> assign(:product_form, to_form(Products.change_product(%Product{})))
      |> assign(:variant_form, to_form(Products.change_product_variant(%ProductVariant{})))
      |> assign(:show_variant_dialog, false)
      |> assign(:variant_dialog_action, :new)
      |> assign(:selected_product_variant, nil)
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
    socket =
      case socket.assigns.live_action do
        :products -> assign_product_index(socket, params)
        :product_new -> assign_product_new(socket)
        :product_show -> assign_product_show(socket, params)
      end

    {:noreply, socket}
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

  def handle_event("validate_product", %{"product" => params}, socket) do
    changeset =
      socket.assigns.selected_product
      |> Products.change_product(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :product_form, to_form(changeset))}
  end

  def handle_event("save_product", %{"product" => params}, socket) do
    case Products.create_product(params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully.")
         |> push_navigate(to: ~p"/admin/products")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :product_form, to_form(changeset))}
    end
  end

  def handle_event("select-product-image", %{"id" => id}, socket) do
    case Enum.find(socket.assigns.selected_product.product_images, &(to_string(&1.id) == id)) do
      nil ->
        {:noreply, socket}

      product_image ->
        {:noreply, assign(socket, :selected_product_image, product_image)}
    end
  end

  def handle_event("reorder-product-images", %{"ids" => ordered_image_ids}, socket) do
    product = socket.assigns.selected_product

    case Products.reorder_product_images(product.id, ordered_image_ids) do
      {:ok, reordered_product_images} ->
        updated_product = %{product | product_images: reordered_product_images}

        {:noreply,
         socket
         |> assign(:selected_product, updated_product)
         |> assign(
           :selected_product_image,
           refreshed_selected_product_image(
             reordered_product_images,
             socket.assigns.selected_product_image
           )
         )
         |> put_flash(:info, "Product image order updated.")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not reorder product images.")}
    end
  end

  def handle_event("open-new-variant-dialog", _params, socket) do
    {:noreply, open_variant_dialog(socket)}
  end

  def handle_event("open-edit-variant-dialog", %{"id" => id}, socket) do
    case find_product_variant(socket.assigns.selected_product, id) do
      nil ->
        {:noreply, put_flash(socket, :error, "Product variant not found.")}

      product_variant ->
        {:noreply, open_variant_dialog(socket, :edit, product_variant)}
    end
  end

  def handle_event("close-new-variant-dialog", _params, socket) do
    {:noreply, close_variant_dialog(socket)}
  end

  def handle_event("close-variant-dialog", _params, socket) do
    {:noreply, close_variant_dialog(socket)}
  end

  def handle_event("validate-variant", %{"product_variant" => params}, socket) do
    changeset =
      socket
      |> variant_changeset_for_action(product_variant_form_params(params))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :variant_form, to_form(changeset))}
  end

  def handle_event("save-variant", %{"product_variant" => params}, socket) do
    product = socket.assigns.selected_product

    case save_product_variant(socket, product, params) do
      {:ok, _product_variant} ->
        refreshed_product = Products.get_admin_product!(product.id)

        {:noreply,
         socket
         |> assign(:selected_product, refreshed_product)
         |> assign(
           :selected_product_image,
           refreshed_selected_product_image(
             refreshed_product.product_images,
             socket.assigns.selected_product_image
           )
         )
         |> close_variant_dialog()
         |> put_flash(:info, variant_success_message(socket.assigns.variant_dialog_action))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:show_variant_dialog, true)
         |> assign(:variant_form, to_form(Map.put(changeset, :action, :validate)))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} variant={:admin}>
      <AdminLive.admin_shell current_scope={@current_scope} active={:products}>
        <%= case @live_action do %>
          <% :products -> %>
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
          <% :product_new -> %>
            <.product_form_page
              form={@product_form}
              collection_options={@product_form_collection_options}
            />
          <% :product_show -> %>
            <.product_show_page
              product={@selected_product}
              selected_image={@selected_product_image}
              variant_form={@variant_form}
              show_variant_dialog={@show_variant_dialog}
              variant_dialog_action={@variant_dialog_action}
            />
        <% end %>
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
          <.icon name="hero-plus" class="size-4" /> New product
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
                  placeholder="Search by Vietnamese or English name"
                  class="input input-bordered join-item w-full min-w-0"
                />
                <button type="submit" class="btn btn-primary join-item">Search</button>
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
                <th class="w-64">Image</th>
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
                <td class="w-64">
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
                    <p class="font-medium">{product.name_vi}</p>
                    <p class="text-sm text-base-content/70">{product.name_en}</p>
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
                      <p class="font-medium">{variant.variant_name_vi}</p>
                      <p class="text-xs text-base-content/70">{variant.variant_name_en}</p>
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
                    view={~p"/admin/products/#{product.id}"}
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

  attr :form, :any, required: true
  attr :collection_options, :list, required: true

  def product_form_page(assigns) do
    ~H"""
    <AdminLive.page_header
      title="New product"
      section="Ecommerce"
      description="Create the base product record before adding variants or images."
    />

    <section class="mt-6 max-w-5xl">
      <div class="card bg-base-100 shadow-sm">
        <div class="card-body">
          <.form for={@form} id="product-form" phx-change="validate_product" phx-submit="save_product">
            <div class="grid gap-4 lg:grid-cols-2">
              <.input
                field={@form[:collection_id]}
                type="select"
                label="Collection"
                options={@collection_options}
              />
              <div></div>
              <.input field={@form[:slug]} type="text" label="Slug" />
              <div></div>
              <.input field={@form[:name_vi]} type="text" label="Vietnamese name" />
              <.input field={@form[:name_en]} type="text" label="English name" />
              <.input
                field={@form[:description_vi]}
                type="textarea"
                label="Vietnamese description"
                class="textarea w-full lg:col-span-2"
              />
              <.input
                field={@form[:description_en]}
                type="textarea"
                label="English description"
                class="textarea w-full lg:col-span-2"
              />
            </div>
            <div class="mt-6 flex justify-end gap-3">
              <.link navigate={~p"/admin/products"} class="btn btn-ghost">Cancel</.link>
              <button type="submit" class="btn btn-primary">Create product</button>
            </div>
          </.form>
        </div>
      </div>
    </section>
    """
  end

  attr :product, Product, required: true
  attr :selected_image, :map, default: nil
  attr :variant_form, :any, required: true
  attr :show_variant_dialog, :boolean, required: true
  attr :variant_dialog_action, :atom, required: true

  def product_show_page(assigns) do
    ~H"""
    <AdminLive.page_header
      title="Product detail"
      section="Ecommerce"
      description="Review the base product information before variants and image management are added."
    >
      <:actions>
        <.link navigate={~p"/admin/products"} class="btn btn-ghost btn-sm">Back to products</.link>
      </:actions>
    </AdminLive.page_header>

    <section class="mt-6 grid gap-6 xl:grid-cols-[minmax(0,2fr)_minmax(18rem,1fr)]">
      <div class="space-y-6">
        <div class="card bg-base-100 shadow-sm">
          <div class="card-body gap-5">
            <div class="flex flex-col gap-3 lg:flex-row lg:items-start lg:justify-between">
              <div class="space-y-2">
                <p class="text-sm font-medium uppercase tracking-[0.2em] text-base-content/50">
                  Product summary
                </p>
                <div>
                  <h2 class="text-2xl font-semibold">{primary_product_name(@product)}</h2>
                  <p class="mt-1 text-sm text-base-content/70">{secondary_product_name(@product)}</p>
                </div>
              </div>
              <div class="badge badge-soft badge-primary">ID #{@product.id}</div>
            </div>

            <div class="grid gap-4 md:grid-cols-2 2xl:grid-cols-4">
              <.detail_item label="Collection" value={product_collection_label(@product.collection)} />
              <.detail_item label="Slug" value={"/#{@product.slug}"} />
              <.detail_item label="English name" value={display_text(@product.name_en)} />
              <.detail_item label="Vietnamese name" value={display_text(@product.name_vi)} />
            </div>
          </div>
        </div>

        <div class="card bg-base-100 shadow-sm">
          <div class="card-body gap-5">
            <div>
              <h2 class="card-title text-base">Product content</h2>
              <p class="text-sm text-base-content/60">
                Base product descriptions only. Variants and image management will be added later.
              </p>
            </div>

            <div class="grid gap-4 2xl:grid-cols-2">
              <.detail_block
                title="English description"
                value={long_text_or_placeholder(@product.description_en)}
              />
              <.detail_block
                title="Vietnamese description"
                value={long_text_or_placeholder(@product.description_vi)}
              />
            </div>
          </div>
        </div>

        <div class="card bg-base-100 shadow-sm">
          <div class="card-body gap-5">
            <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
              <div>
                <h2 class="card-title text-base">Product variants</h2>
                <p class="text-sm text-base-content/60">
                  Create and review variants for the current product, ordered for admin review.
                </p>
              </div>
              <button
                id="open-new-variant-dialog"
                type="button"
                class="btn btn-primary btn-sm"
                phx-click="open-new-variant-dialog"
              >
                New variant
              </button>
            </div>

            <div class="overflow-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th class="w-20">Order</th>
                    <th>Variant VI</th>
                    <th>Variant EN</th>
                    <th>Cost</th>
                    <th>Price</th>
                    <th>Stock</th>
                    <th>Image filename</th>

                    <th class="text-right">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr :if={@product.product_variants == []}>
                    <td colspan="9" class="py-12 text-center text-base-content/60">No variants</td>
                  </tr>
                  <tr :for={variant <- @product.product_variants} class="hover:bg-base-200/40">
                    <td class="align-top">{variant.display_order}</td>
                    <td class="align-top font-medium">
                      {variant.variant_name_vi}
                    </td>
                    <td class="align-top text-base-content/70">{variant.variant_name_en}</td>
                    <td class="align-top">{format_vnd(variant.production_cost)}</td>
                    <td class="align-top">{format_vnd(variant.selling_price)}</td>
                    <td class="align-top">{variant.stock_quantity}</td>
                    <td class="align-top">{display_image_filename(variant.image_filename)}</td>

                    <td class="align-top text-right">
                      <div class="join">
                        <button
                          type="button"
                          class="btn btn-secondary btn-xs join-item"
                          phx-click="open-edit-variant-dialog"
                          phx-value-id={variant.id}
                        >
                          Edit
                        </button>
                        <button type="button" class="btn btn-error btn-xs join-item" disabled>
                          Remove
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <div class="space-y-6">
        <.product_image_preview_panel selected_image={@selected_image} />
        <.product_images_panel
          product_images={@product.product_images}
          selected_image={@selected_image}
        />
      </div>
    </section>

    <.product_variant_dialog
      show={@show_variant_dialog}
      form={@variant_form}
      product={@product}
      action={@variant_dialog_action}
    />
    """
  end

  attr :show, :boolean, required: true
  attr :form, :any, required: true
  attr :product, Product, required: true
  attr :action, :atom, required: true

  def product_variant_dialog(assigns) do
    ~H"""
    <div :if={@show} class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <button
        type="button"
        class="absolute inset-0 bg-base-content/40 backdrop-blur-sm"
        aria-label="Close product variant dialog"
        phx-click="close-variant-dialog"
      />

      <div class="relative z-10 max-h-[calc(100vh-2rem)] w-full max-w-3xl overflow-auto rounded-box bg-base-100 shadow-xl">
        <div class="border-b border-base-300 px-6 py-4">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h2 class="text-lg font-semibold">{variant_dialog_title(@action)}</h2>
              <p class="mt-1 text-sm text-base-content/60">
                {variant_dialog_description(@action, @product)}
              </p>
            </div>
          </div>
        </div>

        <div class="px-6 py-5">
          <.form
            for={@form}
            id="product-variant-form"
            phx-change="validate-variant"
            phx-submit="save-variant"
          >
            <input type="hidden" name="product_variant[product_id]" value={@product.id} />

            <div class="grid gap-4 md:grid-cols-2">
              <.input
                field={@form[:variant_name_vi]}
                type="text"
                label="Vietnamese variant name"
              />
              <.input field={@form[:variant_name_en]} type="text" label="English variant name" />
              <.input
                field={@form[:production_cost]}
                type="number"
                label="Production cost"
                min="0"
              />
              <.input
                field={@form[:selling_price]}
                type="number"
                label="Selling price"
                min="0"
              />
              <.input
                field={@form[:stock_quantity]}
                type="number"
                label="Stock quantity"
                min="0"
              />
              <.input
                field={@form[:display_order]}
                type="number"
                label="Display order"
                min="0"
              />
              <.input
                field={@form[:image_filename]}
                type="text"
                label="Image filename"
              />
            </div>

            <div class="mt-6 flex justify-end gap-3">
              <button
                type="button"
                class="btn btn-ghost"
                phx-click="close-variant-dialog"
              >
                Cancel
              </button>
              <button type="submit" class="btn btn-primary">{variant_submit_label(@action)}</button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  attr :selected_image, :map, default: nil

  def product_image_preview_panel(assigns) do
    ~H"""
    <section class="card bg-base-100 shadow-sm">
      <div class="card-body gap-5">
        <div>
          <h2 class="card-title text-base">Image preview</h2>
          <p class="text-sm text-base-content/60">
            Thumbnail-only preview for the first ordered product image.
          </p>
        </div>

        <div class="overflow-hidden rounded-box border border-base-300 bg-base-200/60">
          <%= cond do %>
            <% preview_path = product_image_preview_path(@selected_image) -> %>
              <img
                src={preview_path}
                alt={@selected_image.filename}
                class="aspect-square w-full object-cover"
              />
            <% true -> %>
              <div class="flex aspect-square items-center justify-center p-6 text-center text-sm text-base-content/60">
                No image
              </div>
          <% end %>
        </div>

        <div class="space-y-2">
          <div class="flex min-w-0 items-center gap-2">
            <div class="min-w-0 grow rounded-box bg-base-200/60 px-3 py-2 text-sm text-base-content/80">
              <p class="truncate">{selected_image_filename(@selected_image)}</p>
            </div>

            <%= if @selected_image do %>
              <button
                id={"copy-product-image-filename-#{@selected_image.id}"}
                type="button"
                class="btn btn-xs"
                phx-hook="CopyToClipboard"
                data-copy-text={@selected_image.filename}
              >
                Copy
              </button>
            <% else %>
              <button type="button" class="btn btn-xs" disabled>Copy</button>
            <% end %>
          </div>

          <div class="flex min-w-0 items-center gap-2">
            <div class="min-w-0 grow rounded-box bg-base-200/60 px-3 py-2 text-sm text-base-content/80">
              <p class="truncate">{selected_image_thumbnail_filename(@selected_image)}</p>
            </div>

            <%= if thumbnail_copy_path = product_image_thumbnail_path(@selected_image) do %>
              <button
                id={"copy-product-image-thumbnail-#{@selected_image.id}"}
                type="button"
                class="btn btn-xs"
                phx-hook="CopyToClipboard"
                data-copy-text={thumbnail_copy_path}
              >
                Copy
              </button>
            <% else %>
              <button type="button" class="btn btn-xs" disabled>Copy</button>
            <% end %>
          </div>
        </div>

        <div class="flex flex-wrap gap-2">
          <button type="button" class="btn btn-error btn-sm" disabled>Delete</button>

          <%= if original_path = product_image_original_path(@selected_image) do %>
            <a
              href={original_path}
              class="btn btn-sm btn-primary"
              target="_blank"
              rel="noopener noreferrer"
            >
              View original
            </a>
          <% else %>
            <button type="button" class="btn btn-ghost btn-sm" disabled>View original</button>
          <% end %>
        </div>
      </div>
    </section>
    """
  end

  attr :product_images, :list, required: true
  attr :selected_image, :map, default: nil

  def product_images_panel(assigns) do
    ~H"""
    <section class="card bg-base-100 shadow-sm">
      <div class="card-body gap-5">
        <div>
          <h2 class="card-title text-base">Product images</h2>
          <p class="text-sm text-base-content/60">
            Read-only thumbnail list ordered by display order.
          </p>
        </div>

        <div
          :if={@product_images == []}
          class="rounded-box border border-dashed border-base-300 p-6 text-sm text-base-content/60"
        >
          No product images
        </div>

        <div :if={@product_images != []} class="space-y-3">
          <div
            id="product-images-sortable"
            phx-hook="ProductImageSortable"
            class="space-y-3"
          >
            <div
              :for={product_image <- @product_images}
              id={"product-image-#{product_image.id}"}
              data-image-id={product_image.id}
              class={[
                "flex items-start gap-3 rounded-box border p-3 transition-colors",
                selected_product_image?(product_image, @selected_image) &&
                  "border-primary bg-primary/5",
                !selected_product_image?(product_image, @selected_image) &&
                  "border-base-300 hover:bg-base-200/40"
              ]}
            >
              <button
                type="button"
                phx-click="select-product-image"
                phx-value-id={product_image.id}
                class="flex min-w-0 grow items-center gap-3 text-left"
              >
                <div class="h-14 w-14 shrink-0 overflow-hidden rounded-box bg-base-200/60">
                  <%= if preview_path = product_image_preview_path(product_image) do %>
                    <img
                      src={preview_path}
                      alt={product_image.filename}
                      class="h-full w-full object-cover"
                    />
                  <% end %>
                </div>

                <div class="min-w-0 grow">
                  <div class="flex items-center justify-between gap-2">
                    <p class="truncate text-sm font-medium">{product_image.filename}</p>
                    <span
                      :if={selected_product_image?(product_image, @selected_image)}
                      class="badge badge-primary badge-xs"
                    >
                      Selected
                    </span>
                  </div>
                  <div class="mt-1 flex flex-wrap gap-x-3 gap-y-1 text-xs text-base-content/60">
                    <span>Order: {product_image.display_order}</span>
                    <span>Thumbnail: {thumbnail_status_label(product_image)}</span>
                  </div>
                </div>
              </button>

              <button
                type="button"
                draggable="true"
                data-role="drag-handle"
                class="btn btn-secondary btn-sm shrink-0 cursor-grab active:cursor-grabbing"
                aria-label={"Drag #{product_image.filename}"}
              >
                Drag
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end

  attr :label, :string, required: true
  attr :value, :string, required: true

  def detail_item(assigns) do
    ~H"""
    <div class="rounded-box bg-base-200/50 p-4">
      <p class="text-xs font-medium uppercase tracking-[0.16em] text-base-content/50">{@label}</p>
      <p class="mt-2 text-sm text-base-content">{@value}</p>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :value, :string, required: true

  def detail_block(assigns) do
    ~H"""
    <div class="rounded-box border border-base-300 p-4">
      <p class="text-sm font-medium">{@title}</p>
      <p class="mt-3 whitespace-pre-wrap text-sm leading-6 text-base-content/80">{@value}</p>
    </div>
    """
  end

  defp assign_product_index(socket, params) do
    product_index = Products.list_admin_products(params)

    socket
    |> assign(:page_title, "Products")
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

  defp assign_product_new(socket) do
    socket
    |> assign(:page_title, "New product")
    |> assign(:selected_product, %Product{})
    |> assign(:selected_product_image, nil)
    |> assign(:product_form, to_form(Products.change_product(%Product{})))
    |> assign(:variant_form, to_form(Products.change_product_variant(%ProductVariant{})))
    |> assign(:show_variant_dialog, false)
    |> assign(:variant_dialog_action, :new)
    |> assign(:selected_product_variant, nil)
    |> assign(:product_form_collection_options, product_form_collection_options())
  end

  defp assign_product_show(socket, %{"id" => id}) do
    product = Products.get_admin_product!(id)

    socket
    |> assign(:page_title, "Product detail")
    |> assign(:selected_product, product)
    |> assign(:selected_product_image, default_selected_product_image(product))
    |> assign(:variant_form, to_form(new_product_variant_changeset(product)))
    |> assign(:show_variant_dialog, false)
    |> assign(:variant_dialog_action, :new)
    |> assign(:selected_product_variant, nil)
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

  defp product_form_collection_options do
    [{"No collection", ""}] ++
      Enum.map(Collections.list_filterable_collections(), fn collection ->
        {product_collection_label(collection), collection.id}
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

  defp default_selected_product_image(product) do
    Enum.find(product.product_images, &(&1.display_order == 0)) ||
      List.first(product.product_images)
  end

  defp refreshed_selected_product_image(product_images, %{id: selected_image_id}) do
    Enum.find(product_images, &(&1.id == selected_image_id)) || List.first(product_images)
  end

  defp refreshed_selected_product_image(product_images, _selected_image),
    do: List.first(product_images)

  defp open_variant_dialog(socket), do: open_variant_dialog(socket, :new)

  defp open_variant_dialog(socket, :new) do
    product = socket.assigns.selected_product

    socket
    |> assign(:show_variant_dialog, true)
    |> assign(:variant_dialog_action, :new)
    |> assign(:selected_product_variant, nil)
    |> assign(:variant_form, to_form(new_product_variant_changeset(product)))
  end

  defp open_variant_dialog(socket, :edit, %ProductVariant{} = product_variant) do
    socket
    |> assign(:show_variant_dialog, true)
    |> assign(:variant_dialog_action, :edit)
    |> assign(:selected_product_variant, product_variant)
    |> assign(:variant_form, to_form(Products.change_product_variant(product_variant)))
  end

  defp close_variant_dialog(socket) do
    product = socket.assigns.selected_product

    socket
    |> assign(:show_variant_dialog, false)
    |> assign(:variant_dialog_action, :new)
    |> assign(:selected_product_variant, nil)
    |> assign(:variant_form, to_form(new_product_variant_changeset(product)))
  end

  defp new_product_variant_changeset(product) do
    product
    |> new_product_variant()
    |> Products.change_product_variant()
  end

  defp new_product_variant(product) do
    %ProductVariant{
      product_id: product.id,
      display_order: Products.next_product_variant_display_order(product.id)
    }
  end

  defp product_variant_form_params(params) do
    params
    |> Map.new()
    |> Map.put("image_filename", blank_to_nil(Map.get(params, "image_filename")))
  end

  defp product_variant_create_attrs(product, params) do
    params
    |> product_variant_form_params()
    |> Map.put("product_id", product.id)
  end

  defp product_variant_update_attrs(%ProductVariant{} = product_variant, params) do
    params
    |> product_variant_form_params()
    |> Map.put("product_id", product_variant.product_id)
  end

  defp save_product_variant(socket, product, params) do
    case socket.assigns.variant_dialog_action do
      :edit ->
        socket.assigns.selected_product_variant
        |> Products.update_product_variant(
          product_variant_update_attrs(socket.assigns.selected_product_variant, params)
        )

      _new ->
        Products.create_product_variant(product_variant_create_attrs(product, params))
    end
  end

  defp variant_changeset_for_action(socket, params) do
    case socket.assigns.variant_dialog_action do
      :edit ->
        Products.change_product_variant(socket.assigns.selected_product_variant, params)

      _new ->
        socket.assigns.selected_product
        |> new_product_variant()
        |> Products.change_product_variant(params)
    end
  end

  defp variant_success_message(:edit), do: "Product variant updated successfully."
  defp variant_success_message(_action), do: "Product variant created successfully."

  defp variant_dialog_title(:edit), do: "Edit product variant"
  defp variant_dialog_title(_action), do: "New product variant"

  defp variant_dialog_description(:edit, product) do
    "Update a variant for #{primary_product_name(product)}."
  end

  defp variant_dialog_description(_action, product) do
    "Create a variant for #{primary_product_name(product)}."
  end

  defp variant_submit_label(:edit), do: "Update variant"
  defp variant_submit_label(_action), do: "Create variant"

  defp find_product_variant(product, variant_id) do
    Enum.find(product.product_variants, &(to_string(&1.id) == to_string(variant_id)))
  end

  defp product_image_thumbnail_path(%{filename: filename, has_thumbnail: true})
       when is_binary(filename) do
    Uploads.thumbnail_filename(filename)
  end

  defp product_image_thumbnail_path(_product_image), do: nil

  defp product_image_preview_path(%{filename: filename, has_thumbnail: true})
       when is_binary(filename) do
    Uploads.thumbnail_filename(filename)
  end

  defp product_image_preview_path(%{filename: filename}) when is_binary(filename), do: filename
  defp product_image_preview_path(_product_image), do: nil

  defp product_image_original_path(%{filename: filename}) when is_binary(filename), do: filename
  defp product_image_original_path(_product_image), do: nil

  defp selected_image_filename(%{filename: filename}) when is_binary(filename), do: filename
  defp selected_image_filename(_product_image), do: "—"

  defp selected_image_thumbnail_filename(%{filename: filename, has_thumbnail: true})
       when is_binary(filename) do
    Uploads.thumbnail_filename(filename)
  end

  defp selected_image_thumbnail_filename(_product_image), do: "—"

  defp thumbnail_status_label(%{has_thumbnail: true}), do: "yes"
  defp thumbnail_status_label(_product_image), do: "no"

  defp selected_product_image?(%{id: image_id}, %{id: selected_id}), do: image_id == selected_id
  defp selected_product_image?(_product_image, _selected_image), do: false

  defp product_collection_label(nil), do: "No collection"

  defp product_collection_label(collection) do
    cond do
      present?(collection.name_vi) -> collection.name_vi
      present?(collection.name_en) -> collection.name_en
      true -> "Collection ##{collection.id}"
    end
  end

  defp present?(value), do: is_binary(value) and String.trim(value) != ""

  defp display_text(value) when is_binary(value) and value != "", do: String.trim(value)
  defp display_text(_value), do: "-"

  defp long_text_or_placeholder(value) when is_binary(value) and value != "",
    do: String.trim(value)

  defp long_text_or_placeholder(_value), do: "No description"

  defp display_image_filename(value) when is_binary(value) and value != "", do: value
  defp display_image_filename(_value), do: "—"

  defp blank_to_nil(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      trimmed_value -> trimmed_value
    end
  end

  defp blank_to_nil(value), do: value

  defp primary_product_name(product) do
    cond do
      present?(product.name_vi) -> product.name_vi
      present?(product.name_en) -> product.name_en
      true -> "Unnamed product"
    end
  end

  defp secondary_product_name(product) do
    cond do
      present?(product.name_vi) and present?(product.name_en) -> product.name_en
      present?(product.name_vi) -> product.name_vi
      present?(product.name_en) -> product.name_en
      true -> "No secondary name"
    end
  end

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
