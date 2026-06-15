# Task 041 - Move admin LiveViews into admin namespace

Date: 2026-06-15

## Goal

Refactor admin-only LiveView modules into an explicit admin namespace.

Current modules:

```text
CaHeoShopWeb.CollectionLive
CaHeoShopWeb.ProductLive
```

are currently placed directly under:

```text
lib/ca_heo_shop_web/live
```

These LiveViews are used for admin features, so they should be moved under:

```text
lib/ca_heo_shop_web/live/admin
```

and renamed to:

```text
CaHeoShopWeb.Admin.CollectionLive
CaHeoShopWeb.Admin.ProductLive
```

## Required changes

### 1. Move CollectionLive

Move the file:

```text
lib/ca_heo_shop_web/live/collection_live.ex
```

to:

```text
lib/ca_heo_shop_web/live/admin/collection_live.ex
```

Update the module name from:

```elixir
defmodule CaHeoShopWeb.CollectionLive do
```

to:

```elixir
defmodule CaHeoShopWeb.Admin.CollectionLive do
```

### 2. Move ProductLive

Move the file:

```text
lib/ca_heo_shop_web/live/product_live.ex
```

to:

```text
lib/ca_heo_shop_web/live/admin/product_live.ex
```

Update the module name from:

```elixir
defmodule CaHeoShopWeb.ProductLive do
```

to:

```elixir
defmodule CaHeoShopWeb.Admin.ProductLive do
```

### 3. Update router references

Search for all router references to the old modules.

Likely file:

```text
lib/ca_heo_shop_web/router.ex
```

Replace references like:

```elixir
CollectionLive
ProductLive
```

or:

```elixir
CaHeoShopWeb.CollectionLive
CaHeoShopWeb.ProductLive
```

with the new admin modules:

```elixir
CaHeoShopWeb.Admin.CollectionLive
CaHeoShopWeb.Admin.ProductLive
```

Use the style that best matches the existing router conventions.

### 4. Update ProductLive and CollectionLive tests

Update all tests related to the moved admin LiveViews.

Search for test files and references related to:

```text
CollectionLive
ProductLive
CaHeoShopWeb.CollectionLive
CaHeoShopWeb.ProductLive
collection_live_test.exs
product_live_test.exs
```

Likely test paths may include:

```text
test/ca_heo_shop_web/live/collection_live_test.exs
test/ca_heo_shop_web/live/product_live_test.exs
```

Move or rename test files if needed so they match the new admin namespace.

Recommended target paths:

```text
test/ca_heo_shop_web/live/admin/collection_live_test.exs
test/ca_heo_shop_web/live/admin/product_live_test.exs
```

Update test module names from:

```elixir
defmodule CaHeoShopWeb.CollectionLiveTest do
defmodule CaHeoShopWeb.ProductLiveTest do
```

to:

```elixir
defmodule CaHeoShopWeb.Admin.CollectionLiveTest do
defmodule CaHeoShopWeb.Admin.ProductLiveTest do
```

Update any test imports, aliases, route references, LiveView module assertions, or helper references that still point to the old module names.

The tests should continue verifying the same behavior as before.

Do not rewrite test intent or reduce test coverage.

### 5. Update all project references

Search the whole project for:

```text
CaHeoShopWeb.CollectionLive
CaHeoShopWeb.ProductLive
CollectionLive
ProductLive
collection_live.ex
product_live.ex
collection_live_test.exs
product_live_test.exs
```

Update only references that point to these admin LiveViews or their tests.

Possible places:

```text
lib/ca_heo_shop_web/router.ex
test/ca_heo_shop_web/live
test/ca_heo_shop_web/controllers
docs
tasks
```

### 6. Keep URLs unchanged

Do not change admin routes or browser paths.

The following paths should continue working exactly as before:

```text
/admin/collections
/admin/products
/admin/products/:id
/admin/products/:id/edit
```

Do not introduce route behavior changes in this task.

### 7. Keep behavior unchanged

This task is a namespace and file-organization refactor only.

Do not change:

```text
collection business logic
product business logic
LiveView assigns
events
params
streams
forms
uploads
image preview logic
delete image logic
variant logic
database queries
UI layout
authorization rules
test scenarios
test coverage
```

## Verification

Run:

```bash
mix format
mix compile
mix test
```

Also manually verify that these admin pages still load:

```text
/admin/collections
/admin/products
/admin/products/:id
```

## Acceptance criteria

* `collection_live.ex` exists at:

```text
lib/ca_heo_shop_web/live/admin/collection_live.ex
```

* `product_live.ex` exists at:

```text
lib/ca_heo_shop_web/live/admin/product_live.ex
```

* Old LiveView files no longer exist at:

```text
lib/ca_heo_shop_web/live/collection_live.ex
lib/ca_heo_shop_web/live/product_live.ex
```

* Module names are updated to:

```elixir
CaHeoShopWeb.Admin.CollectionLive
CaHeoShopWeb.Admin.ProductLive
```

* Router references use the new module names.
* ProductLive tests are updated to use the new admin namespace.
* CollectionLive tests are updated to use the new admin namespace.
* Test file locations are updated if needed to match the new namespace.
* Existing admin URLs continue to work.
* No functional behavior is changed.
* Existing test coverage is preserved.
* `mix format`, `mix compile`, and `mix test` pass.
