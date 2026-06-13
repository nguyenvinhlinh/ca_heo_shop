defmodule CaHeoShopWeb.Router do
  use CaHeoShopWeb, :router

  import CaHeoShopWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CaHeoShopWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", CaHeoShopWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ca_heo_shop, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CaHeoShopWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", CaHeoShopWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{CaHeoShopWeb.UserAuth, :require_authenticated}] do
      live "/admin", AdminLive, :dashboard
      live "/admin/products", ProductLive, :products
      live "/admin/products/new", ProductLive, :product_new
      live "/admin/products/:id", ProductLive, :product_show
      live "/admin/products/:slug/edit", AdminLive, :product_edit
      live "/admin/products/:slug/delete", AdminLive, :product_delete
      live "/admin/orders", AdminLive, :orders
      live "/admin/customers", AdminLive, :customers
      live "/admin/collections", CollectionLive, :collections
      live "/admin/collections/new", CollectionLive, :collection_new
      live "/admin/collections/:slug/edit", CollectionLive, :collection_edit
      live "/admin/settings", AdminLive, :settings

      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", CaHeoShopWeb do
    pipe_through [:browser]

    get "/collection_images/:filename", CollectionImageController, :show

    live_session :current_user,
      on_mount: [{CaHeoShopWeb.UserAuth, :mount_current_scope}] do
      live "/", StorefrontLive, :home
      live "/products", StorefrontLive, :products
      live "/products/:slug", StorefrontLive, :product
      live "/collections", StorefrontLive, :collections
      live "/collections/:slug", StorefrontLive, :collection
      live "/cart", StorefrontLive, :cart
      live "/checkout", StorefrontLive, :checkout
      live "/account", StorefrontLive, :account
      live "/orders", StorefrontLive, :orders
      live "/account/settings", StorefrontLive, :account_settings

      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
