defmodule CaHeoShopWeb.StorefrontLive do
  use CaHeoShopWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    products = mock_products()
    product = Enum.find(products, &(&1.slug == params["slug"]))
    collections = mock_collections()
    collection = Enum.find(collections, &(&1.slug == params["slug"]))

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action, product))
      |> assign(:products, products)
      |> assign(:featured_products, Enum.take(products, 3))
      |> assign(:collections, collections)
      |> assign(:collection, collection)
      |> assign(:cart_items, mock_cart_items(products))
      |> assign(:product, product)
      |> assign(:related_products, related_products(products, product))
      |> assign(:customer, mock_customer())
      |> assign(:mock_user, mock_user())
      |> assign(:checkout_form, to_form(%{}, as: :checkout))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} variant={:storefront}>
      <.storefront_shell
        current_scope={@current_scope}
        mock_user={@mock_user}
        collections={@collections}
      >
        <%= case @live_action do %>
          <% :home -> %>
            <.home_page products={@featured_products} collections={@collections} />
          <% :products -> %>
            <.products_page products={@products} />
          <% :product -> %>
            <.product_page product={@product} related_products={@related_products} />
          <% :collections -> %>
            <.collections_page collections={@collections} />
          <% :collection -> %>
            <.collection_page collection={@collection} products={@products} />
          <% :cart -> %>
            <.cart_page cart_items={@cart_items} />
          <% :checkout -> %>
            <.checkout_page cart_items={@cart_items} form={@checkout_form} />
          <% :account -> %>
            <.account_page customer={@customer} />
          <% :orders -> %>
            <.orders_page customer={@customer} />
          <% :account_settings -> %>
            <.account_settings_page customer={@customer} />
        <% end %>
      </.storefront_shell>
    </Layouts.app>
    """
  end

  attr :current_scope, :map, default: nil
  attr :mock_user, :map, required: true
  attr :collections, :list, required: true
  slot :inner_block, required: true

  def storefront_shell(assigns) do
    ~H"""
    <div class="mx-auto min-h-screen max-w-[120rem] bg-base-100 text-base-content">
      <div class="drawer">
        <input id="storefront-drawer" type="checkbox" class="drawer-toggle" />
        <div class="drawer-content flex min-h-screen flex-col">
          <.storefront_header
            current_scope={@current_scope}
            mock_user={@mock_user}
            collections={@collections}
          />
          <main class="grow">{render_slot(@inner_block)}</main>
          <.storefront_footer />
        </div>
        <div class="drawer-side z-50 lg:hidden">
          <label for="storefront-drawer" aria-label="Close menu" class="drawer-overlay"></label>
          <nav class="menu min-h-full w-80 gap-2 bg-base-200 p-8">
            <li><.link navigate={~p"/products"}>Products</.link></li>
            <li>
              <details open>
                <summary>Collections</summary>
                <ul>
                  <li><.link navigate={~p"/collections"}>All Collections</.link></li>
                  <li :for={collection <- @collections}>
                    <.link navigate={~p"/collections/#{collection.slug}"}>
                      {collection.name}
                    </.link>
                  </li>
                </ul>
              </details>
            </li>
            <li><.link navigate={~p"/cart"}>Cart</.link></li>
          </nav>
        </div>
      </div>
    </div>
    """
  end

  attr :current_scope, :map, default: nil
  attr :mock_user, :map, required: true
  attr :collections, :list, required: true

  def storefront_header(assigns) do
    assigns =
      assign(assigns, :display_user, %{
        name: user_display_name(assigns.current_scope, assigns.mock_user),
        email: user_display_email(assigns.current_scope, assigns.mock_user)
      })

    ~H"""
    <header class="navbar sticky top-0 z-30 border-b-2 border-base-content/10 bg-base-100/80 px-5 backdrop-blur-lg md:px-10">
      <div class="navbar-start">
        <label for="storefront-drawer" class="btn btn-ghost lg:hidden" aria-label="Open menu">
          <.icon name="hero-bars-3" class="size-5" />
        </label>
        <.link navigate={~p"/"} class="btn btn-ghost text-xl font-bold">Ca Heo DIY</.link>
      </div>
      <nav class="navbar-center hidden lg:flex">
        <ul class="menu menu-horizontal gap-4 font-semibold">
          <li><.link navigate={~p"/products"}>Products</.link></li>
          <li>
            <details>
              <summary>Collections</summary>
              <ul class="rounded-box bg-base-100 p-2 shadow">
                <li><.link navigate={~p"/collections"}>All Collections</.link></li>
                <li :for={collection <- @collections}>
                  <.link navigate={~p"/collections/#{collection.slug}"}>
                    {collection.name}
                  </.link>
                </li>
              </ul>
            </details>
          </li>
          <li><.link navigate={~p"/cart"}>Cart</.link></li>
        </ul>
      </nav>
      <div class="navbar-end gap-1">
        <div class="dropdown dropdown-end">
          <button
            type="button"
            tabindex="0"
            class="btn btn-ghost btn-sm max-w-48 gap-2 rounded-full"
          >
            <span class="hidden truncate md:inline">{@display_user.name}</span>
          </button>
          <ul
            tabindex="0"
            class="menu dropdown-content z-40 mt-3 w-64 rounded-box bg-base-100 p-2 shadow"
          >
            <li class="menu-title">
              <span class="truncate">{@display_user.email}</span>
            </li>
            <li><.link navigate={~p"/orders"}>Orders</.link></li>
            <li>
              <%= if @current_scope do %>
                <.link navigate={~p"/users/settings"}>Settings</.link>
              <% else %>
                <.link navigate={~p"/account/settings"}>Settings</.link>
              <% end %>
            </li>
            <li>
              <%= if @current_scope do %>
                <.link href={~p"/users/log-out"} method="delete">Log out</.link>
              <% else %>
                <button type="button">Logout</button>
              <% end %>
            </li>
          </ul>
        </div>
        <Layouts.theme_toggle />
      </div>
    </header>
    """
  end

  def storefront_footer(assigns) do
    ~H"""
    <footer class="border-t border-base-content/10">
      <div class="footer footer-vertical gap-8 px-5 py-10 text-base-content md:footer-horizontal lg:px-14">
        <aside>
          <p class="text-xl font-bold">Ca Heo DIY</p>
          <p class="max-w-sm text-base-content/70">
            Small-batch 3D printed products, DIY kits, garden tools, and custom maker projects.
          </p>
        </aside>
        <nav>
          <h2 class="footer-title opacity-80">Collections</h2>
          <.link navigate={~p"/collections"}>All collections</.link>
          <.link navigate={~p"/collections/3d-printed-products"}>3D printed</.link>
          <.link navigate={~p"/collections/diy-kits"}>DIY kits</.link>
        </nav>
        <nav>
          <h2 class="footer-title opacity-80">Support</h2>
          <a>Custom orders</a>
          <a>Shipping notes</a>
          <a>Contact the shop</a>
        </nav>
        <nav>
          <h2 class="footer-title opacity-80">Payment</h2>
          <div class="flex gap-3">
            <span class="badge badge-outline">Bank transfer</span>
            <span class="badge badge-outline">COD</span>
          </div>
        </nav>
      </div>
      <div class="border-t border-base-content/10 px-5 py-5 text-center text-xs text-base-content/50">
        Mock storefront skeleton. No real cart, checkout, payment, or order persistence yet.
      </div>
    </footer>
    """
  end

  attr :products, :list, required: true
  attr :collections, :list, required: true

  def home_page(assigns) do
    ~H"""
    <section class="px-0 py-0 lg:px-14 lg:py-5">
      <div class="relative h-[28rem] overflow-hidden bg-black md:h-[40rem] lg:rounded-3xl">
        <img
          src={~p"/images/storefront/hero-workshop.svg"}
          alt=""
          class="absolute inset-0 block h-full w-full object-cover object-center"
        />
        <div class="absolute inset-0 bg-base-content/30"></div>
        <div
          class="absolute inset-0 left-5 flex flex-col justify-center md:left-10 lg:left-20 "
        >
          <div class="badge badge-sm mb-4 rounded-full font-medium italic">
            MOCK STORE PREVIEW
          </div>
          <h1 class="max-w-2xl text-4xl font-semibold text-base-100 md:text-5xl lg:text-[4rem]">
            Custom-made DIY products for makers, students, and home growers
          </h1>
          <p class="mt-5 max-w-xl text-sm text-base-100/80 md:text-lg">
            Explore small-batch 3D printed accessories, hands-on kits, and hydroponic tools designed by Ca Heo DIY.
          </p>
          <.link navigate={~p"/products"} class="btn mt-8 w-40 rounded-full">
            Shop Now <.icon name="hero-arrow-up-right" class="size-4" />
          </.link>
        </div>
      </div>
    </section>

    <section class="px-5 py-10 lg:px-14">
      <div class="grid gap-4 xl:grid-cols-4">
        <.feature_card
          icon="hero-truck"
          title="Local delivery"
          text="Mock shipping notes for Vietnam-based orders."
        />
        <.feature_card
          icon="hero-wrench-screwdriver"
          title="Custom builds"
          text="Request small product changes before production."
        />
        <.feature_card
          icon="hero-cube"
          title="Made in batches"
          text="Low inventory, clear availability, practical designs."
        />
        <.feature_card
          icon="hero-chat-bubble-left-right"
          title="Direct support"
          text="Contact the owner when a product needs clarification."
        />
      </div>
    </section>

    <section class="px-5 py-10 lg:px-14">
      <div class="flex items-center justify-between">
        <h2 class="text-2xl font-bold lg:text-4xl">Featured Products</h2>
        <.link navigate={~p"/products"} class="btn btn-outline btn-sm rounded-full">View all</.link>
      </div>
      <div class="mt-10 grid gap-6 md:grid-cols-2 xl:grid-cols-3">
        <.product_card :for={product <- @products} product={product} />
      </div>
    </section>

    <section class="px-5 py-10 lg:px-14">
      <h2 class="text-2xl font-bold lg:text-4xl">Shop by Collections</h2>
      <div class="carousel mt-10 gap-3 xl:hidden">
        <.collection_card :for={collection <- @collections} collection={collection} mobile />
      </div>
      <div class="mt-10 hidden gap-5 xl:grid xl:grid-cols-4">
        <.collection_card :for={collection <- @collections} collection={collection} />
      </div>
    </section>

    <section class="py-10 lg:px-14">
      <div class="relative overflow-hidden lg:rounded-3xl">
        <img
          src={~p"/images/storefront/custom-order.svg"}
          alt=""
          class="h-[35rem] w-full object-cover"
        />
        <div class="absolute bottom-10 left-5 max-w-xl text-base-content md:bottom-20 lg:left-20">
          <div class="badge badge-sm w-fit border border-base-content/20 bg-base-100/80 font-semibold uppercase tracking-wide text-base-content/80 backdrop-blur-md">
            Custom Order Preview
          </div>
          <h2 class="mt-3 text-3xl font-semibold leading-tight md:text-5xl">
            Need a printed part or DIY kit variation?
          </h2>
          <p class="mt-4 max-w-lg text-base-content/70">
            This skeleton keeps custom-order discovery visible while the real ordering workflow is still being designed.
          </p>
          <.link
            navigate={~p"/products/custom-plant-holder"}
            class="btn mt-8 rounded-full bg-base-content text-base-100 hover:bg-base-content/80"
          >
            See Example
          </.link>
        </div>
      </div>
    </section>
    """
  end

  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :text, :string, required: true

  def feature_card(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center rounded-lg border border-base-content/10 p-8 text-center">
      <div class="rounded-lg bg-base-200 p-3">
        <.icon name={@icon} class="size-7 opacity-70" />
      </div>
      <h3 class="mt-4 text-lg font-bold">{@title}</h3>
      <p class="mt-1 text-sm font-medium text-base-content/70">{@text}</p>
    </div>
    """
  end

  attr :products, :list, required: true

  def products_page(assigns) do
    ~H"""
    <section class="flex h-52 w-full flex-col items-center justify-center border-b border-base-content/10 bg-base-100">
      <h1 class="text-center text-4xl font-medium text-base-content md:text-5xl">Products</h1>
      <div class="mt-4 h-px w-24 bg-base-content/30"></div>
    </section>

    <section class="px-5 pb-20 pt-10 lg:px-14">
      <div class="drawer md:drawer-open">
        <input id="product-filter-drawer" type="checkbox" class="drawer-toggle" />
        <aside class="drawer-side top-16 z-20 md:border-r md:border-base-content/10">
          <label for="product-filter-drawer" aria-label="Close filters" class="drawer-overlay">
          </label>
          <div class="min-h-full w-64 bg-base-100 p-4 md:w-52 lg:w-80">
            <h2 class="my-7 font-bold">Filter Area</h2>
            <div class="space-y-7 text-sm">
              <div>
                <p class="mb-3 font-semibold">Category</p>
                <label class="flex cursor-pointer items-center gap-2">
                  <input type="checkbox" class="checkbox checkbox-sm" /> 3D Printed
                </label>
                <label class="mt-3 flex cursor-pointer items-center gap-2">
                  <input type="checkbox" class="checkbox checkbox-sm" /> DIY Kits
                </label>
                <label class="mt-3 flex cursor-pointer items-center gap-2">
                  <input type="checkbox" class="checkbox checkbox-sm" /> Gardening
                </label>
              </div>
              <div>
                <p class="mb-3 font-semibold">Price placeholder</p>
                <input type="range" min="0" max="100" value="60" class="range range-xs" />
                <p class="mt-2 text-base-content/60">Search and filters are static in this task.</p>
              </div>
            </div>
          </div>
        </aside>

        <div class="drawer-content flex flex-col md:pl-10">
          <div class="mb-4 flex items-center justify-between gap-3">
            <label
              for="product-filter-drawer"
              class="btn w-28 border border-base-content/40 bg-transparent text-xs font-medium hover:bg-base-100 md:hidden"
            >
              <.icon name="hero-adjustments-horizontal" class="size-4" /> Filter By
            </label>
            <label class="input input-bordered flex max-w-xs items-center gap-2 rounded-full">
              <.icon name="hero-magnifying-glass" class="size-4 opacity-60" />
              <input type="search" class="grow" placeholder="Search products" />
            </label>
            <div class="dropdown dropdown-end">
              <div
                tabindex="0"
                role="button"
                class="btn border border-base-content/20 bg-transparent px-5 text-xs font-medium hover:bg-base-100 lg:w-48 lg:text-sm"
              >
                Sort: Newer <.icon name="hero-chevron-down" class="size-4" />
              </div>
              <ul
                tabindex="0"
                class="menu dropdown-content z-10 w-52 rounded-box bg-base-100 p-2 shadow"
              >
                <li><button>Newer</button></li>
                <li><button>Price: low to high</button></li>
                <li><button>Price: high to low</button></li>
              </ul>
            </div>
          </div>

          <div class="grid gap-6 md:grid-cols-2 xl:grid-cols-3">
            <.product_card :for={product <- @products} product={product} />
          </div>

          <div class="mt-10 flex flex-col items-center justify-between gap-4 border-t border-base-content/10 pt-6 sm:flex-row">
            <p class="text-sm text-base-content/60">
              Showing 1 to {length(@products)} of {length(@products)} mock products
            </p>
            <div class="join">
              <button class="btn join-item btn-sm">1</button>
              <button class="btn join-item btn-sm btn-disabled">2</button>
              <button class="btn join-item btn-sm btn-disabled">Next</button>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end

  attr :product, :map, required: true
  attr :related_products, :list, required: true

  def product_page(%{product: nil} = assigns) do
    ~H"""
    <section class="px-5 py-20 text-center lg:px-14">
      <h1 class="text-3xl font-bold">Product not found</h1>
      <p class="mt-3 text-base-content/60">This mock product slug does not exist.</p>
      <.link navigate={~p"/products"} class="btn btn-neutral mt-8 rounded-full">
        Back to products
      </.link>
    </section>
    """
  end

  def product_page(assigns) do
    ~H"""
    <section class="px-5 pb-20 pt-10 lg:px-14">
      <div class="flex flex-col gap-8 lg:grid lg:grid-cols-2 lg:gap-12">
        <div>
          <div class="grid gap-3 lg:grid-cols-[5rem_1fr]">
            <div class="hidden flex-col gap-3 lg:flex">
              <img
                src={@product.image}
                alt=""
                class="rounded-lg border-2 border-base-content object-cover"
              />
              <img src={@product.alt_image} alt="" class="rounded-lg object-cover opacity-70" />
            </div>
            <img src={@product.image} alt={@product.name} class="w-full rounded-lg object-cover" />
          </div>
        </div>

        <div>
          <div class="badge badge-outline mb-4">{@product.category}</div>
          <h1 class="text-3xl font-bold md:text-4xl">{@product.name}</h1>
          <div class="mt-4 flex items-center gap-3">
            <span class="text-2xl font-semibold lg:text-3xl">{@product.price}</span>
            <span class="badge rounded-xl bg-success/20 font-semibold text-success">Mock stock</span>
          </div>
          <p class="mt-1 text-base-content/50">+ local shipping estimate</p>
          <div class="divider"></div>
          <p class="text-base-content/70">{@product.description}</p>

          <div class="mt-6 space-y-3">
            <label :for={variant <- @product.variants} class="flex cursor-pointer items-center gap-2">
              <input type="radio" name="variant" class="radio radio-sm" /> {variant}
            </label>
          </div>

          <div class="mt-8">
            <button id="add-to-cart-button" class="btn btn-neutral btn-block">
              <.icon name="hero-shopping-cart" class="size-5" /> Add to cart
            </button>
          </div>

          <div class="mt-10 flex flex-col gap-2">
            <.product_info title="Description" open>{@product.description}</.product_info>
            <.product_info title="Specifications">
              <ul class="list-disc space-y-1 pl-5">
                <li :for={spec <- @product.specifications}>{spec}</li>
              </ul>
            </.product_info>
            <.product_info title="Availability">
              {@product.availability}. This is mock data and does not reserve inventory.
            </.product_info>
          </div>
        </div>
      </div>

      <div class="divider mt-20 lg:mt-36"></div>
      <div class="mb-28 mt-20">
        <div class="flex justify-between">
          <h2 class="text-2xl font-semibold lg:text-4xl">Explore more</h2>
        </div>
        <div class="mt-10 grid gap-6 md:grid-cols-2 xl:grid-cols-3">
          <.product_card :for={product <- @related_products} product={product} />
        </div>
      </div>
    </section>
    """
  end

  attr :title, :string, required: true
  attr :open, :boolean, default: false
  slot :inner_block, required: true

  def product_info(assigns) do
    ~H"""
    <div class="collapse collapse-arrow rounded-xl border border-base-content/10">
      <input type="radio" name="product-info" checked={@open} />
      <div class="collapse-title font-medium">{@title}</div>
      <div class="collapse-content text-sm text-base-content/60">{render_slot(@inner_block)}</div>
    </div>
    """
  end

  attr :cart_items, :list, required: true

  def cart_page(assigns) do
    assigns = assign(assigns, :subtotal, cart_subtotal(assigns.cart_items))

    ~H"""
    <section class="flex h-52 w-full flex-col items-center justify-center border-b border-base-content/10 bg-base-100">
      <h1 class="text-4xl font-medium md:text-5xl">Cart</h1>
      <div class="mt-4 h-px w-24 bg-base-content/30"></div>
    </section>
    <section class="px-5 py-10 lg:px-14">
      <div class="grid gap-8 lg:grid-cols-[1fr_24rem]">
        <div class="space-y-4">
          <div
            :for={item <- @cart_items}
            class="flex gap-4 rounded-3xl border border-base-content/10 p-4"
          >
            <img src={item.product.image} alt="" class="size-24 rounded-2xl object-cover" />
            <div class="grow">
              <h2 class="font-bold">{item.product.name}</h2>
              <p class="text-sm text-base-content/60">{item.product.price}</p>
              <div class="mt-4 join">
                <button class="btn join-item btn-sm">-</button>
                <button class="btn join-item btn-sm">{item.quantity}</button>
                <button class="btn join-item btn-sm">+</button>
              </div>
            </div>
          </div>
        </div>
        <aside class="h-fit rounded-3xl border border-base-content/10 p-6">
          <h2 class="text-xl font-bold">Order Summary</h2>
          <div class="mt-5 flex justify-between">
            <span>Subtotal</span>
            <span class="font-semibold">{format_money(@subtotal)}</span>
          </div>
          <p class="mt-4 text-sm text-base-content/60">
            Shipping note placeholder. Final shipping will be confirmed by the shop owner.
          </p>
          <.link navigate={~p"/checkout"} class="btn btn-neutral btn-block mt-6">Checkout</.link>
        </aside>
      </div>
    </section>
    """
  end

  attr :cart_items, :list, required: true
  attr :form, Phoenix.HTML.Form, required: true

  def checkout_page(assigns) do
    assigns = assign(assigns, :subtotal, cart_subtotal(assigns.cart_items))

    ~H"""
    <section class="flex h-52 w-full flex-col items-center justify-center border-b border-base-content/10 bg-base-100">
      <h1 class="text-4xl font-medium md:text-5xl">Checkout</h1>
      <div class="mt-4 h-px w-24 bg-base-content/30"></div>
    </section>
    <section class="px-5 py-10 lg:px-14">
      <div class="grid gap-8 lg:grid-cols-[1fr_24rem]">
        <.form for={@form} id="checkout-form" class="space-y-6">
          <div class="rounded-3xl border border-base-content/10 p-6">
            <h2 class="text-xl font-bold">Customer information</h2>
            <div class="mt-5 grid gap-4 md:grid-cols-2">
              <.input field={@form[:name]} label="Full name" placeholder="Nguyen Van A" />
              <.input field={@form[:phone]} label="Phone" placeholder="0900000000" />
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                placeholder="customer@example.com"
              />
            </div>
          </div>
          <div class="rounded-3xl border border-base-content/10 p-6">
            <h2 class="text-xl font-bold">Shipping address</h2>
            <div class="mt-5 grid gap-4 md:grid-cols-2">
              <.input field={@form[:address]} label="Address" placeholder="Street and ward" />
              <.input field={@form[:city]} label="City" placeholder="Ho Chi Minh City" />
              <.input
                field={@form[:note]}
                type="textarea"
                label="Order note"
                placeholder="Mock checkout only"
              />
            </div>
          </div>
          <div class="rounded-3xl border border-base-content/10 p-6">
            <h2 class="text-xl font-bold">Payment method</h2>
            <p class="mt-3 text-base-content/60">
              Payment placeholder. No payment is processed in this skeleton.
            </p>
            <button type="button" id="place-order-button" class="btn btn-neutral mt-6">
              Place order
            </button>
          </div>
        </.form>
        <aside class="h-fit rounded-3xl border border-base-content/10 p-6">
          <h2 class="text-xl font-bold">Order Summary</h2>
          <div :for={item <- @cart_items} class="mt-4 flex gap-3">
            <img src={item.product.image} alt="" class="size-14 rounded-xl object-cover" />
            <div class="grow text-sm">
              <p class="font-semibold">{item.product.name}</p>
              <p class="text-base-content/60">Qty {item.quantity}</p>
            </div>
          </div>
          <div class="divider"></div>
          <div class="flex justify-between">
            <span>Subtotal</span>
            <span class="font-semibold">{format_money(@subtotal)}</span>
          </div>
        </aside>
      </div>
    </section>
    """
  end

  attr :customer, :map, required: true

  def account_page(assigns) do
    ~H"""
    <section class="flex h-52 w-full flex-col items-center justify-center border-b border-base-content/10 bg-base-100">
      <h1 class="text-4xl font-medium md:text-5xl">Account</h1>
      <div class="mt-4 h-px w-24 bg-base-content/30"></div>
    </section>
    <section class="px-5 py-10 lg:px-14">
      <div class="grid gap-6 lg:grid-cols-3">
        <div class="rounded-3xl border border-base-content/10 p-6">
          <h2 class="text-xl font-bold">Overview</h2>
          <p class="mt-3 text-base-content/60">
            Mock account area for exploring future profile, address, and order concepts.
          </p>
        </div>
        <div class="rounded-3xl border border-base-content/10 p-6">
          <h2 class="text-xl font-bold">Profile Summary</h2>
          <p class="mt-3 font-semibold">{@customer.name}</p>
          <p class="text-base-content/60">{@customer.email}</p>
        </div>
        <div class="rounded-3xl border border-base-content/10 p-6">
          <h2 class="text-xl font-bold">Address Placeholder</h2>
          <p class="mt-3 text-base-content/60">{@customer.address}</p>
        </div>
      </div>
      <div class="mt-6 rounded-3xl border border-base-content/10 p-6">
        <h2 class="text-xl font-bold">Recent Orders Placeholder</h2>
        <div class="mt-5 overflow-auto">
          <table class="table">
            <thead>
              <tr>
                <th>Order</th>
                <th>Status</th>
                <th>Total</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={order <- @customer.orders}>
                <td>{order.id}</td>
                <td><span class="badge badge-outline">{order.status}</span></td>
                <td>{order.total}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>
    """
  end

  attr :collections, :list, required: true

  def collections_page(assigns) do
    ~H"""
    <section class="flex h-52 w-full flex-col items-center justify-center border-b border-base-content/10 bg-base-100">
      <h1 class="text-center text-4xl font-medium text-base-content md:text-5xl">
        Collections
      </h1>
      <div class="mt-4 h-px w-24 bg-base-content/30"></div>
    </section>

    <section class="px-5 py-10 lg:px-14">
      <div class="grid gap-6 md:grid-cols-2 xl:grid-cols-5">
        <.collection_card :for={collection <- @collections} collection={collection} />
      </div>
    </section>
    """
  end

  attr :collection, :map, required: true
  attr :products, :list, required: true

  def collection_page(%{collection: nil} = assigns) do
    ~H"""
    <section class="px-5 py-20 text-center lg:px-14">
      <h1 class="text-3xl font-bold">Collection not found</h1>
      <p class="mt-3 text-base-content/60">This mock collection slug does not exist.</p>
      <.link navigate={~p"/collections"} class="btn btn-neutral mt-8 rounded-full">
        Back to collections
      </.link>
    </section>
    """
  end

  def collection_page(assigns) do
    assigns =
      assign(
        assigns,
        :collection_products,
        Enum.filter(assigns.products, &(&1.collection_slug == assigns.collection.slug))
      )

    ~H"""
    <section class="relative h-64 overflow-hidden border-b border-base-content/10">
      <img
        src={@collection.image}
        alt=""
        class="absolute inset-0 block h-full w-full object-cover object-center"
      />
      <div class="absolute inset-0 bg-base-content/35"></div>
      <div
        class="relative flex h-full flex-col items-center justify-center px-5 text-center"
      >
        <p class="badge badge-sm rounded-full">Mock Collection</p>
        <h1 class="mt-4 text-4xl font-semibold text-base-100 md:text-5xl">
          {@collection.name}
        </h1>
        <p class="mt-4 max-w-2xl text-base-100/80">{@collection.description}</p>
      </div>
    </section>

    <section class="px-5 py-10 lg:px-14">
      <div class="grid gap-6 md:grid-cols-2 xl:grid-cols-3">
        <.product_card :for={product <- @collection_products} product={product} />
      </div>
      <p :if={@collection_products == []} class="text-base-content/60">No products found.</p>
    </section>
    """
  end

  attr :customer, :map, required: true

  def orders_page(assigns) do
    ~H"""
    <section class="flex h-52 w-full flex-col items-center justify-center border-b border-base-content/10 bg-base-100">
      <h1 class="text-4xl font-medium md:text-5xl">Orders</h1>
      <div class="mt-4 h-px w-24 bg-base-content/30"></div>
    </section>

    <section class="px-5 py-10 lg:px-14">
      <div class="overflow-auto rounded-3xl border border-base-content/10">
        <table class="table">
          <thead>
            <tr>
              <th>Order</th>
              <th>Status</th>
              <th>Total</th>
              <th>Note</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={order <- @customer.orders}>
              <td class="font-semibold">{order.id}</td>
              <td><span class="badge badge-outline">{order.status}</span></td>
              <td>{order.total}</td>
              <td class="text-base-content/60">{order.note}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
    """
  end

  attr :customer, :map, required: true

  def account_settings_page(assigns) do
    ~H"""
    <section class="flex h-52 w-full flex-col items-center justify-center border-b border-base-content/10 bg-base-100">
      <h1 class="text-center text-4xl font-medium md:text-5xl">Account Settings</h1>
      <div class="mt-4 h-px w-24 bg-base-content/30"></div>
    </section>

    <section class="px-5 py-10 lg:px-14">
      <div class="grid gap-6 lg:grid-cols-3">
        <section class="rounded-3xl border border-base-content/10 p-6">
          <h2 class="text-xl font-bold">Full Name</h2>
          <p class="mt-3 text-base-content/60">Placeholder profile editing for {@customer.name}.</p>
          <button class="btn btn-outline mt-6 rounded-full" type="button">Edit name</button>
        </section>
        <section class="rounded-3xl border border-base-content/10 p-6">
          <h2 class="text-xl font-bold">Password</h2>
          <p class="mt-3 text-base-content/60">
            Placeholder password management. No credentials are changed here.
          </p>
          <button class="btn btn-outline mt-6 rounded-full" type="button">Change password</button>
        </section>
        <section class="rounded-3xl border border-base-content/10 p-6">
          <h2 class="text-xl font-bold">Address</h2>
          <p class="mt-3 text-base-content/60">{@customer.address}</p>
          <button class="btn btn-outline mt-6 rounded-full" type="button">Edit address</button>
        </section>
      </div>
    </section>
    """
  end

  attr :product, :map, required: true

  def product_card(assigns) do
    ~H"""
    <.link navigate={~p"/products/#{@product.slug}"} class="group relative block">
      <div class="relative overflow-hidden rounded-3xl">
        <img
          src={@product.image}
          alt={@product.name}
          class="aspect-[4/3] w-full object-cover transition duration-500 group-hover:scale-105"
        />
        <div
          :if={@product.sale}
          class="badge badge-neutral absolute left-0 top-5 rounded-l-none rounded-r-xl font-semibold"
        >
          Sale
        </div>
        <div class="absolute bottom-4 left-4 right-4 flex items-center justify-between rounded-2xl bg-base-100/80 px-4 py-3 shadow-sm backdrop-blur">
          <div>
            <h3 class="font-bold">{@product.name}</h3>
            <p class="text-sm">{@product.price}</p>
          </div>
          <span class="btn btn-circle btn-xs">
            <.icon name="hero-chevron-right" class="size-3" />
          </span>
        </div>
      </div>
    </.link>
    """
  end

  attr :collection, :map, required: true
  attr :mobile, :boolean, default: false

  def collection_card(assigns) do
    ~H"""
    <div class={[@mobile && "carousel-item w-72", "relative overflow-hidden rounded-3xl"]}>
      <img src={@collection.image} alt={@collection.name} class="h-72 w-full object-cover" />
      <div class="absolute inset-x-0 bottom-10 flex justify-center">
        <.link navigate={~p"/collections/#{@collection.slug}"} class="btn rounded-full">
          {@collection.name} <.icon name="hero-arrow-up-right" class="size-4" />
        </.link>
      </div>
    </div>
    """
  end

  defp page_title(:home, _product), do: "Ca Heo DIY"
  defp page_title(:products, _product), do: "Products"
  defp page_title(:product, nil), do: "Product not found"
  defp page_title(:product, product), do: product.name
  defp page_title(:collections, _product), do: "Collections"
  defp page_title(:collection, _product), do: "Collection"
  defp page_title(:cart, _product), do: "Cart"
  defp page_title(:checkout, _product), do: "Checkout"
  defp page_title(:account, _product), do: "Account"
  defp page_title(:orders, _product), do: "Orders"
  defp page_title(:account_settings, _product), do: "Account Settings"

  defp user_display_name(%{user: %{email: email}}, _mock_user), do: email
  defp user_display_name(_current_scope, mock_user), do: mock_user.name

  defp user_display_email(%{user: %{email: email}}, _mock_user), do: email
  defp user_display_email(_current_scope, mock_user), do: mock_user.email

  defp related_products(_products, nil), do: []

  defp related_products(products, product) do
    products
    |> Enum.reject(&(&1.slug == product.slug))
    |> Enum.filter(&(&1.category == product.category))
    |> then(fn related -> if related == [], do: Enum.take(products, 3), else: related end)
    |> Enum.take(3)
  end

  defp cart_subtotal(items) do
    Enum.reduce(items, 0, fn item, total -> total + item.product.price_cents * item.quantity end)
  end

  defp format_money(cents), do: "#{Integer.to_string(div(cents, 1000))}.000 VND"

  defp mock_cart_items(products) do
    products
    |> Enum.take(2)
    |> Enum.with_index(1)
    |> Enum.map(fn {product, quantity} -> %{product: product, quantity: quantity} end)
  end

  defp mock_customer do
    %{
      name: "Mock Customer",
      email: "customer@example.com",
      address: "District 1, Ho Chi Minh City",
      orders: [
        %{
          id: "MOCK-1001",
          status: "Draft",
          total: "180.000 VND",
          note: "Electronics kit order preview"
        },
        %{
          id: "MOCK-1000",
          status: "Delivered",
          total: "95.000 VND",
          note: "Plant holder sample order"
        }
      ]
    }
  end

  defp mock_user do
    %{name: "Halo Nguyen", email: "halo@example.com"}
  end

  defp mock_collections do
    [
      %{
        name: "3D Printed Products",
        slug: "3d-printed-products",
        image: ~p"/images/storefront/category-prints.svg",
        description: "Small-batch printed tools, organizers, parts, and practical desk objects."
      },
      %{
        name: "DIY Kits",
        slug: "diy-kits",
        image: ~p"/images/storefront/category-kits.svg",
        description: "Starter kits and simple maker projects for learning by building."
      },
      %{
        name: "Home Accessories",
        slug: "home-accessories",
        image: ~p"/images/storefront/product-organizer.svg",
        description: "Functional home and desk accessories from Ca Heo DIY experiments."
      },
      %{
        name: "Hydroponics",
        slug: "hydroponics",
        image: ~p"/images/storefront/category-garden.svg",
        description: "Plant holders and compact growing accessories for home gardeners."
      },
      %{
        name: "Custom Orders",
        slug: "custom-orders",
        image: ~p"/images/storefront/custom-order.svg",
        description: "Placeholder collection for custom print requests and product variations."
      }
    ]
  end

  defp mock_products do
    [
      %{
        name: "Modular Desk Organizer",
        slug: "modular-desk-organizer",
        description:
          "A 3D printed desk tray system with movable cups for tools, pens, and small components.",
        price: "120.000 VND",
        price_cents: 120_000,
        image: ~p"/images/storefront/product-organizer.svg",
        alt_image: ~p"/images/storefront/category-prints.svg",
        category: "3D Printed",
        collection_slug: "3d-printed-products",
        availability: "Available for small-batch production",
        sale: true,
        variants: ["Matte black PLA", "White PLA", "Custom color request"],
        specifications: ["PLA plastic", "Approx. 18 x 12 cm", "Made to order in 2-3 days"]
      },
      %{
        name: "Starter Electronics Kit",
        slug: "starter-electronics-kit",
        description:
          "A beginner-friendly DIY kit with breadboard parts and a small guide for simple circuits.",
        price: "180.000 VND",
        price_cents: 180_000,
        image: ~p"/images/storefront/product-kit.svg",
        alt_image: ~p"/images/storefront/category-kits.svg",
        category: "DIY Kits",
        collection_slug: "diy-kits",
        availability: "Mock stock: 8 kits",
        sale: false,
        variants: ["Basic kit", "Kit with sensors"],
        specifications: [
          "Breadboard included",
          "Reusable jumper wires",
          "Educational project notes"
        ]
      },
      %{
        name: "Custom Plant Holder",
        slug: "custom-plant-holder",
        description:
          "A compact plant holder for hydroponic experiments, sized for small home grow setups.",
        price: "95.000 VND",
        price_cents: 95_000,
        image: ~p"/images/storefront/product-holder.svg",
        alt_image: ~p"/images/storefront/category-garden.svg",
        category: "Hydroponics",
        collection_slug: "hydroponics",
        availability: "Custom sizing available",
        sale: false,
        variants: ["Small cup", "Medium cup", "Custom diameter"],
        specifications: [
          "Water-resistant design",
          "Multiple cup sizes",
          "Designed for small herbs"
        ]
      },
      %{
        name: "Prototype Print Request",
        slug: "prototype-print-request",
        description:
          "A placeholder product for exploring custom 3D print request flows before persistence exists.",
        price: "Contact for quote",
        price_cents: 0,
        image: ~p"/images/storefront/custom-order.svg",
        alt_image: ~p"/images/storefront/hero-workshop.svg",
        category: "Custom Orders",
        collection_slug: "custom-orders",
        availability: "Quote required",
        sale: false,
        variants: ["Send STL file", "Design assistance", "Repair part"],
        specifications: [
          "Mock workflow only",
          "No file upload yet",
          "Owner reviews request manually"
        ]
      }
    ]
  end
end
