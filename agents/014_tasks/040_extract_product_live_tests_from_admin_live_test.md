# Task 040: Extract ProductLive Tests From AdminLiveTest

## Filename

`040_extract_product_live_tests_from_admin_live_test.md`

## Goal

Move `/admin/products/:id` LiveView tests out of the broad admin test module and into a dedicated `ProductLive` test module.

The current `ProductLive` surface is large enough that keeping its behavior inside `AdminLiveTest` makes failures harder to localize and increases UI-text coupling.

## Background

The admin product detail page now contains multiple independent behaviors:

```text
Product summary rendering
Product summary edit dialog
Product content edit dialog
Product variant create/edit/delete/reorder
Product image preview/select/reorder
```

These behaviors belong to:

```text
CaHeoShopWeb.Admin.ProductLive
```

but many of the tests currently live in:

```text
test/ca_heo_shop_web/live/admin_live_test.exs
```

That test file has become too broad for this feature area.

## Route

Use the existing authenticated admin route:

```text
/admin/products/:id
```

Do not change routing behavior in this task.

## Authorization Requirement

Keep the existing authenticated admin access behavior unchanged.

If `/admin/*` authorization is already enforced elsewhere, reuse it exactly as-is.

Do not add or modify role logic in this task.

## Scope

Refactor test organization only.

Expected result:

```text
ProductLive tests live in a dedicated test module/file
AdminLiveTest keeps only tests that truly belong to broader admin-shell behavior
```

Likely files:

```text
test/ca_heo_shop_web/live/admin_live_test.exs
test/ca_heo_shop_web/live/admin/product_live_test.exs
```

If the project prefers an admin namespace path, this is also acceptable:

```text
test/ca_heo_shop_web/live/admin/product_live_test.exs
```

Use the structure that best matches the current repo conventions, but keep the test module clearly focused on `ProductLive`.

## Implementation Notes

Move product-detail-specific tests out of `AdminLiveTest`, including behavior around:

```text
page rendering
summary dialog
content dialog
variant CRUD
variant ordering
image preview
image selection
image ordering
```

Keep helper setup and fixtures readable.

Group the dedicated test file with `describe` blocks where helpful, for example:

```text
describe "product detail page"
describe "product summary dialog"
describe "product content dialog"
describe "product variants"
describe "product images"
```

Do not change application behavior just to satisfy the test refactor unless a real test bug is discovered.

## Do Not Implement

Do not implement:

```text
new product detail features
UI redesign
route changes
authorization changes
fixture redesign unrelated to ProductLive coverage
context-layer behavior changes unless required to keep tests valid
```

This task is about test ownership and maintainability.

## Acceptance Criteria

Expected outcome:

```text
ProductLive coverage is no longer stored in AdminLiveTest
The new dedicated ProductLive test file passes
AdminLiveTest remains green after the move
The full relevant test suite still passes
```

Recommended verification:

```text
mix test test/ca_heo_shop_web/live/admin_live_test.exs
mix test test/ca_heo_shop_web/live/admin/product_live_test.exs
mix test
```
