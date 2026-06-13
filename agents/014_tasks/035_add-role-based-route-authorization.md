# Task 035: Add Role-Based Route Authorization

## Filename

`035_add_role_based_route_authorization.md`

## Goal

Add route authorization based on user role.

Supported roles already exist from Task 033:

```text id="9mk6qh"
system
admin
customer
```

This task controls which URL paths each role can access.

Authorization rules:

```text id="ak057p"
system   -> only /system and /system/*
admin    -> only /admin and /admin/*
customer -> only /products, /products/*, and /cart
```

This task should not add business features inside `/system`.

`/system` can be an empty placeholder page for now if needed.

## Dependencies

This task depends on:

```text id="ct7ufr"
Task 033: users.role exists
Task 034: login works with email or username
```

Do not start this task before role and login identity are working.

## Important Design Decision

Authorization is strict by role.

Do not treat `system` as a super admin.

Do not allow:

```text id="0q7q6a"
system -> /admin
system -> /products
admin -> /system
admin -> /products
customer -> /admin
customer -> /system
```

Each role has its own allowed area.

## Scope

Implement role-based route protection for:

```text id="8zyubk"
/system
/system/*
/admin
/admin/*
/products
/products/*
/cart
```

Likely files:

```text id="6mu9i5"
lib/ca_heo_shop_web/router.ex
lib/ca_heo_shop_web/user_auth.ex
lib/ca_heo_shop_web/live/system_home_live.ex
test/ca_heo_shop_web/user_auth_test.exs
test/ca_heo_shop_web/controllers/user_session_controller_test.exs
test/ca_heo_shop_web/live/*_test.exs
```

Actual files may differ depending on the current generated Phoenix auth structure.

## Do Not Implement

Do not implement:

```text id="e55a4n"
system dashboard features
admin business authorization rules
admin CRUD permissions
customer account page permissions
role management UI
changing user roles from UI
permission tables
policy modules
database changes
```

This task is only route-level authorization.

## Authorization Rules

### System Role

Allowed:

```text id="1tn12b"
/system
/system/*
```

Denied:

```text id="5jse6d"
/admin
/admin/*
/products
/products/*
/cart
```

### Admin Role

Allowed:

```text id="x20avc"
/admin
/admin/*
```

Denied:

```text id="ur5l7v"
/system
/system/*
/products
/products/*
/cart
```

### Customer Role

Allowed:

```text id="pzmlzg"
/products
/products/*
/cart
```

Denied:

```text id="uojlmb"
/system
/system/*
/admin
/admin/*
```

## Auth Routes Exception

Keep normal authentication routes usable where needed.

Examples:

```text id="6qad8r"
/users/log-in
/users/log-out
/users/settings
```

Do not break logout.

A logged-in user should always be able to log out.

If `/users/settings` is currently implemented, leave its current behavior unchanged unless it conflicts heavily with the router structure.

This task focuses on app-domain routes:

```text id="swbe34"
/system
/admin
/products
/cart
```

## Router Requirements

Update:

```text id="hf29jx"
lib/ca_heo_shop_web/router.ex
```

Create role-specific pipelines or scopes.

Recommended pipeline names:

```elixir id="f7vsrr"
pipeline :require_system_user do
  plug :require_authenticated_user
  plug :require_user_role, "system"
end

pipeline :require_admin_user do
  plug :require_authenticated_user
  plug :require_user_role, "admin"
end

pipeline :require_customer_user do
  plug :require_authenticated_user
  plug :require_user_role, "customer"
end
```

Then apply them to route scopes:

```elixir id="u7upg2"
scope "/system", CaHeoShopWeb.System, as: :system do
  pipe_through [:browser, :require_system_user]

  live "/", HomeLive, :index
end
```

```elixir id="bzjvau"
scope "/admin", CaHeoShopWeb.Admin, as: :admin do
  pipe_through [:browser, :require_admin_user]

  live "/", DashboardLive, :index
  # Keep existing admin routes here.
end
```

```elixir id="xq2g9k"
scope "/", CaHeoShopWeb do
  pipe_through [:browser, :require_customer_user]

  live "/products", ProductLive.Index, :index
  live "/products/:slug", ProductLive.Show, :show
  live "/cart", CartLive.Index, :index
end
```

Adjust module names to match the existing app.

Do not duplicate existing routes.

Move existing routes into the correct protected scope if needed.

## UserAuth Requirements

Update:

```text id="7ajxnb"
lib/ca_heo_shop_web/user_auth.ex
```

Add role authorization helper.

Example:

```elixir id="c9x8zl"
def require_user_role(conn, expected_role) do
  current_user = conn.assigns[:current_user]

  if current_user && current_user.role == expected_role do
    conn
  else
    conn
    |> put_flash(:error, "You are not allowed to access this page.")
    |> redirect(to: unauthorized_redirect_path(current_user))
    |> halt()
  end
end
```

Add redirect helper:

```elixir id="uuz2zx"
defp unauthorized_redirect_path(%{role: "system"}), do: "/system"
defp unauthorized_redirect_path(%{role: "admin"}), do: "/admin"
defp unauthorized_redirect_path(%{role: "customer"}), do: "/products"
defp unauthorized_redirect_path(_), do: "/users/log-in"
```

Use existing route helpers if the project prefers verified routes:

```elixir id="xq02rm"
~p"/system"
~p"/admin"
~p"/products"
~p"/users/log-in"
```

## LiveView Requirements

If the project uses LiveView `on_mount` authentication, add role-based `on_mount` hooks.

Recommended hooks:

```elixir id="9w4a48"
on_mount :require_system_user
on_mount :require_admin_user
on_mount :require_customer_user
```

Each hook should:

```text id="5m8scv"
load current_user
check role
allow matching role
redirect non-matching role
```

If route-level plugs already protect the initial HTTP request, still protect LiveView mounts where the existing auth system expects it.

Do not leave LiveViews accessible through direct mount or live navigation bypass.

## System Placeholder Page

If `/system` does not exist yet, create a minimal placeholder LiveView.

Example file:

```text id="shykfw"
lib/ca_heo_shop_web/live/system/home_live.ex
```

Example content:

```elixir id="q8dz1k"
defmodule CaHeoShopWeb.System.HomeLive do
  use CaHeoShopWeb, :live_view

  def render(assigns) do
    ~H"""
    <main class="p-6">
      <h1 class="text-2xl font-bold">System</h1>
      <p class="mt-2 text-base-content/70">
        System area placeholder.
      </p>
    </main>
    """
  end
end
```

Keep it simple.

Feature work for `/system` belongs to a future task.

## Admin Routes

Protect existing admin routes:

```text id="mzczqb"
/admin
/admin/*
```

Only users with:

```text id="73ztnx"
role = admin
```

can access them.

Do not allow `system` users to access `/admin`.

## Customer Routes

Protect:

```text id="42cm25"
/products
/products/*
/cart
```

Only users with:

```text id="ye330m"
role = customer
```

can access them.

For this task, do not add `/checkout`, `/orders`, `/account`, or `/collections` unless they already exist and must be moved deliberately.

The requested customer allowlist is only:

```text id="1vmsmp"
/products*
/cart
```

Interpret `/products*` as:

```text id="w8bwmn"
/products
/products/*
```

## Unauthorized Behavior

When a logged-in user accesses a forbidden path:

```text id="i8pr61"
redirect to that user's own home path
show generic forbidden flash
```

Role home paths:

```text id="pre5el"
system   -> /system
admin    -> /admin
customer -> /products
```

Flash message:

```text id="pudalo"
You are not allowed to access this page.
```

Do not reveal detailed permission internals.

## Unauthenticated Behavior

When a visitor who is not logged in accesses protected paths:

```text id="zfggoq"
/system
/admin
/products
/cart
```

redirect to:

```text id="5pm3cf"
/users/log-in
```

Use the existing Phoenix auth behavior if already implemented.

## After Login Behavior

If the current login flow redirects all users to the same path, update it to redirect by role.

After successful login:

```text id="viq5uz"
system   -> /system
admin    -> /admin
customer -> /products
```

Do not implement permission checks beyond this redirect.

If the user was trying to access a valid protected path before login, the existing `user_return_to` behavior may still be respected only when that path is allowed for the user's role.

If `user_return_to` points to a forbidden path, redirect to the user's role home path instead.

## Tests

Add or update tests for unauthenticated access.

Unauthenticated users should be redirected to login for:

```text id="otxdgt"
/system
/admin
/products
/cart
```

Add tests for system role.

System user can access:

```text id="1g01fb"
/system
```

System user cannot access:

```text id="3i2u7c"
/admin
/products
/cart
```

Add tests for admin role.

Admin user can access:

```text id="o8o0v3"
/admin
```

Admin user cannot access:

```text id="5gw5br"
/system
/products
/cart
```

Add tests for customer role.

Customer user can access:

```text id="v93w2e"
/products
/products/:slug
/cart
```

Customer user cannot access:

```text id="1g5j8u"
/system
/admin
```

Add tests for login redirects.

Successful login redirects:

```text id="nn9ljr"
system -> /system
admin -> /admin
customer -> /products
```

Add tests for forbidden redirect.

When a logged-in user accesses a forbidden route, redirect to own role home:

```text id="grud8i"
system forbidden path -> /system
admin forbidden path -> /admin
customer forbidden path -> /products
```

## Test Helpers

Create or update test helpers for role users.

Suggested helpers:

```elixir id="d9o7mi"
system_user_fixture(attrs \\ %{})
admin_user_fixture(attrs \\ %{})
customer_user_fixture(attrs \\ %{})
```

Each helper should create a user with the correct role.

Use Task 033 schema rules:

```text id="5xd1vn"
system can use username-only
admin can use username-only
customer can use email
```

Example:

```elixir id="6lhqpg"
system_user_fixture(%{
  username: "system_test_user",
  role: "system"
})
```

```elixir id="e90rmu"
admin_user_fixture(%{
  username: "admin_test_user",
  role: "admin"
})
```

```elixir id="0rbrpa"
customer_user_fixture(%{
  email: unique_user_email(),
  role: "customer"
})
```

## Acceptance Criteria

The task is complete when:

```text id="ijqonu"
mix test passes
unauthenticated users cannot access /system
unauthenticated users cannot access /admin
unauthenticated users cannot access /products
unauthenticated users cannot access /cart
system users can access /system
system users cannot access /admin
system users cannot access /products
system users cannot access /cart
admin users can access /admin
admin users cannot access /system
admin users cannot access /products
admin users cannot access /cart
customer users can access /products
customer users can access /products/*
customer users can access /cart
customer users cannot access /system
customer users cannot access /admin
successful system login redirects to /system
successful admin login redirects to /admin
successful customer login redirects to /products
/system placeholder exists if no system page existed before
no system features are implemented yet
no permission table is added
no role management UI is added
```

## Notes

Keep this task focused.

This task answers only:

```text id="zfyxuh"
Which role can enter which route group?
```

Future tasks can add:

```text id="1n5xrs"
system account management
admin dashboard permissions
customer order pages
customer account pages
permission tables
policy modules
role management UI
```
