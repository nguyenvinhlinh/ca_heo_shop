# Nexus Dashboard Design Guideline

## 1. Overview

Nexus Dashboard is an HTML admin template built with Tailwind CSS v4, daisyUI v5, Alpine.js, Vite, Iconify, and Lucide icons. The source workflow lives under `/home/nguyenvinhlinh/Projects/ca_heo_shop/web_templates/nexus-html@4.0.0/src`, and generated pages live under the template `html` directory.

The template uses a partial-based source structure. Shared layout elements are composed with `<load src="partials/...">`, especially `partials/head.html`, `partials/sidebar.html`, `partials/topbar.html`, `partials/rightbar.html`, `partials/footer.html`, and `partials/footer-scripts.html`.

For Ca Heo DIY admin pages, follow the existing Nexus structure rather than inventing a new admin design system. Use daisyUI components, Tailwind utilities, and Iconify Lucide icons in the same density and visual style shown in the template.

Primary references inspected:

- `src/starter.html`
- `src/partials/sidebar.html`
- `src/partials/topbar.html`
- `src/partials/rightbar.html`
- `src/styles/daisyui.css`
- `src/styles/pages/layout.css`
- `src/styles/core/components.css`
- `src/apps-ecommerce-products.html`
- `src/apps-ecommerce-products-create.html`
- `src/apps-ecommerce-order-details.html`
- `src/pages-settings.html`
- `src/dashboards-ecommerce.html`
- `src/components-layouts-page-title.html`
- `src/components-blocks-stats.html`

## 2. Layout Guidelines

Use the admin shell pattern from `src/starter.html`.

The standard admin page structure is:

```html
<div class="size-full">
    <div class="flex">
        <load src="partials/sidebar.html" />

        <div class="flex h-screen min-w-0 grow flex-col overflow-auto">
            <load src="partials/topbar.html" />

            <div id="layout-content">
                Page content
            </div>

            <load src="partials/footer.html" />
        </div>
    </div>

    <load src="partials/rightbar.html" />
</div>
```

`#layout-content` is the main content container. It uses responsive padding from `src/styles/pages/layout.css`: `p-3`, `sm:p-4`, and `md:p-6`. Place page title blocks and all content inside this container.

The main content column uses `h-screen`, `min-w-0`, `grow`, `flex-col`, and `overflow-auto`. Keep these behaviors when translating the layout to Phoenix components so the sidebar and topbar remain fixed relative to the application shell.

The sidebar width is defined by `--layout-sidebar-width: 256px`. The sidebar is a fixed-width column on desktop and becomes a hidden overlay on screens below the `lg` breakpoint. Mobile behavior is controlled through hidden checkbox triggers:

- `#layout-sidebar-toggle-trigger`
- `#layout-sidebar-hover-trigger`
- `#layout-sidebar-hover`

The topbar is sticky, `min-h-16`, `max-h-16`, and uses the theme-specific `--layout-topbar-background`.

The rightbar is a daisyUI `drawer drawer-end` used for theme, direction, font, sidebar theme, and fullscreen customization. Future business admin pages usually do not need their own rightbar, but should coexist with the shared rightbar shell.

## 3. Navigation Guidelines

The sidebar is the primary admin navigation surface. It is organized into labeled groups:

- Overview
- Apps
- Extras
- Components access at the bottom

Navigation items use:

- `.menu-label` for section labels
- `.menu-item` for direct links
- daisyUI `.collapse` for expandable groups
- Lucide icons via `span class="iconify lucide--..."`
- `span.grow` for the menu label text
- `lucide--chevron-right` as the expandable arrow

Direct links follow this shape:

```html
<a class="menu-item" href="./apps-ecommerce-products.html">
    <span class="iconify lucide--store size-4"></span>
    <span class="grow">Products</span>
</a>
```

Expandable navigation follows the daisyUI collapse pattern. The checked input expands the section, and the CSS rotates the arrow. Active states are applied by `public/js/app.js`, which compares the current URL with sidebar links, adds `.active`, and opens the parent collapse.

For new Ca Heo DIY admin sections, add them under a relevant group rather than creating a new navigation model. Product, category, inventory, and order management belong naturally in an ecommerce/admin group.

Topbar navigation includes:

- Sidebar toggle button
- Search button and search modal
- Theme/customization trigger
- Notification dropdowns/drawers
- Profile drawer/menu

Do not duplicate sidebar navigation in the topbar. Use the topbar for global tools and account/status actions.

Breadcrumbs appear in most admin pages beside the page title. The common pattern is:

```html
<div class="flex items-center justify-between">
    <p class="text-lg font-medium">Products</p>
    <div class="breadcrumbs hidden p-0 text-sm sm:inline">
        <ul>
            <li><a href="./dashboards-ecommerce.html">Nexus</a></li>
            <li>Ecommerce</li>
            <li class="opacity-80">Products</li>
        </ul>
    </div>
</div>
```

Hide breadcrumbs on small screens with `hidden sm:inline`.

## 4. Page Patterns

### Dashboard Pages

Dashboard pages use a compact page title, then grids of metric cards, charts, tables, and list widgets. `src/dashboards-ecommerce.html` is the strongest ecommerce reference.

Common dashboard structure:

- Page title and breadcrumb row
- `mt-6` content spacing
- Stats grid using `grid gap-5 lg:grid-cols-2 xl:grid-cols-4`
- Larger widget grid using `grid grid-cols-1 gap-6 xl:grid-cols-12`
- Cards with `bg-base-100 shadow-sm`
- Charts inside cards with headings, tabs, summary values, and chart containers

Use dashboard pages for admin overview screens, not for record CRUD.

### Listing Pages

Listing pages use a page title and breadcrumb row, followed by a table card. `src/apps-ecommerce-products.html` is the main reference.

Common listing structure:

- Card wrapper: `card bg-base-100 shadow-sm`
- Card body often set to `p-0`
- Toolbar row: `flex items-center justify-between px-5 pt-5`
- Search input on the left
- Filters next to search, hidden on small screens when needed
- Primary create action on the right
- Secondary actions in a dropdown
- `overflow-auto` wrapper around the table
- Pagination footer with per-page select, count text, and circular page buttons

Use listing pages for products, categories, inventory records, orders, customers, and similar admin resources.

### Detail Pages

Detail pages use a two-column or 12-column grid with summary and supporting cards. `src/apps-ecommerce-order-details.html` uses `grid grid-cols-1 gap-6 lg:grid-cols-12`, with the main content in `lg:col-span-8 2xl:col-span-9`.

Detail pages often include:

- Header with entity identifier and timestamp
- Primary action button in the card header
- Main table or entity summary
- Supporting cards for customer, payment, address, timeline, or status data
- `card card-border bg-base-100` when content should feel structured and stable

Use detail pages for order details, customer details, product details, or inventory transaction details.

### Settings Pages

Settings pages can use a richer intro banner and a wide form card. `src/pages-settings.html` uses:

- `sm:container`
- A colored hero-like header with `bg-primary/10 rounded-box`
- A large `card bg-base-100 card-border mt-6`
- Sections arranged in grids, with labels and explanatory copy on the left and form controls on the right

Use this pattern for account, shop configuration, and admin preferences.

### Component Pages

The template has a separate component-demo shell using `components-layout` IDs and `partials/components-layout/...`. Do not use this shell for Ca Heo DIY admin product pages. It is documentation/demo infrastructure.

## 5. Table Patterns

Tables are standard daisyUI `.table` components inside a horizontal overflow wrapper.

Use:

```html
<div class="mt-4 overflow-auto">
    <table class="table">
        ...
    </table>
</div>
```

For dense management rows, use:

- `hover:bg-base-200/40`
- `cursor-pointer`
- `*:text-nowrap` on rows or the table when horizontal overflow is expected
- `checkbox checkbox-sm` for bulk selection
- `btn btn-square btn-ghost btn-sm` for row actions
- `btn btn-square btn-error btn-outline btn-sm border-transparent` for destructive row actions

Product/customer/order identity cells usually combine an image or avatar with text:

```html
<div class="flex items-center space-x-3 truncate">
    <img class="rounded-box size-10" ... />
    <div>
        <p class="font-medium">Item name</p>
        <p class="text-base-content/60 text-xs">#CODE</p>
    </div>
</div>
```

Status values use semantic colors and badges:

- `text-success` for available/positive inline status
- `badge badge-success badge-sm badge-soft`
- `badge badge-info badge-sm badge-soft`
- `badge badge-error badge-sm badge-soft`
- `badge badge-primary badge-sm badge-soft`

Pagination uses a footer row:

- Left: per-page selector with `select select-xs w-18`
- Center: count text hidden below `lg`
- Right: circular page buttons using `btn btn-circle sm:btn-sm btn-xs`
- Active page uses `btn-primary`

## 6. Form Patterns

Forms are grouped into cards. Create/edit screens usually use multiple cards in a responsive grid. `src/apps-ecommerce-products-create.html` uses `grid grid-cols-1 gap-6 md:grid-cols-2`.

Use cards for form sections:

```html
<div class="card bg-base-100 shadow-sm">
    <div class="card-body">
        <div class="card-title">Basic Information</div>
        <fieldset class="fieldset mt-2 grid grid-cols-1 gap-4 lg:grid-cols-2">
            ...
        </fieldset>
    </div>
</div>
```

Labels use `fieldset-label`; inputs use daisyUI `input`, `select`, `textarea`, `toggle`, `checkbox`, and `radio` classes. Controls should usually be full width with `w-full`.

Use `space-y-2` around a label and field. Use `lg:grid-cols-2` for paired fields and `lg:col-span-2` for full-width textareas. For fields with prefixes/suffixes/icons, wrap the input in a label with class `input w-full`.

Examples:

- Currency prefix: `lucide--dollar-sign`
- Percentage suffix: `lucide--percent`
- Unit suffix text: `gm`, `In`
- Toggle row: `flex items-center gap-4`

Action rows are placed below the form grid:

```html
<div class="mt-6 flex justify-end gap-3">
    <a class="btn btn-sm btn-ghost">Cancel</a>
    <a class="btn btn-sm btn-primary">Save</a>
</div>
```

Use `btn-primary` for the primary submit/save action, `btn-ghost` for cancel/back actions, and include Lucide icons when the action benefits from visual recognition.

## 7. Card Patterns

Nexus uses cards heavily but keeps them compact and work-focused.

Common card variants:

- `card bg-base-100 shadow-sm` for dashboard widgets and management sections
- `card card-border bg-base-100` for detail/settings sections where a border is clearer than a shadow
- `card-body p-0` when the card contains a table or custom header/footer
- `card-body gap-2` for stat cards
- `card-title` for section titles

Stats cards usually include:

- Label in `text-base-content/80 font-medium`
- Large value in `text-2xl font-semibold`
- Trend badge in `badge badge-soft badge-success badge-sm` or `badge-error`
- Supporting comparison text in `text-base-content/60 text-sm`
- Small icon container using `bg-base-200 rounded-box flex items-center p-2`

Information cards in detail pages often begin with a small internal header strip:

```html
<p class="bg-base-200 rounded-box px-3 py-2 font-medium">Customer Details</p>
```

Use cards to group real admin data or repeated widgets. Avoid decorative card nesting that does not match the template.

## 8. Modal Patterns

Nexus uses native `<dialog>` elements with daisyUI modal classes.

Basic confirmation modal:

```html
<dialog id="resource_delete" class="modal">
    <div class="modal-box">
        <div class="flex items-center justify-between text-lg font-medium">
            Confirm Delete
            <form method="dialog">
                <button class="btn btn-sm btn-ghost btn-circle" aria-label="Close modal">
                    <span class="iconify lucide--x size-4"></span>
                </button>
            </form>
        </div>
        <p class="py-4">Confirmation message.</p>
        <div class="modal-action">
            <form method="dialog">
                <button class="btn btn-ghost btn-sm">No</button>
            </form>
            <form method="dialog">
                <button class="btn btn-sm btn-error">Yes, delete it</button>
            </form>
        </div>
    </div>
    <form method="dialog" class="modal-backdrop">
        <button>close</button>
    </form>
</dialog>
```

Open modals with `document.getElementById("...")?.showModal()` or the shorter template style where the element ID is available as a global variable.

Use modals for:

- Destructive confirmations
- Focused upload/edit actions
- Global search

Use drawers for persistent side panels such as profile details, notifications, and customization.

## 9. Visual Design System

### Typography

The default font is Inclusive Sans. Additional configured options are DM Sans, Wix Madefor Text, and AR One Sans. Font switching is controlled through `data-font-family`.

Configured text sizes:

- `text-xs`: 12px
- `text-sm`: 14px
- `text-base`: 16px
- `text-lg`: 18px
- `text-xl`: 20px

Admin page headings commonly use `text-lg font-medium`. Dashboard metric values use `text-2xl font-semibold` or larger chart headline values like `text-4xl font-semibold`.

Use opacity-based text colors for hierarchy:

- Primary text: `text-base-content`
- Secondary text: `text-base-content/80`
- Muted text: `text-base-content/60`
- Very quiet labels or separators: `text-base-content/25` to `/30`

### Color

Use daisyUI semantic colors so theme switching works:

- Surfaces: `bg-base-100`, `bg-base-200`, `bg-base-300`
- Text: `text-base-content`
- Brand/action: `primary`, `secondary`, `accent`
- Status: `success`, `warning`, `error`, `info`

Theme variables are defined in `src/styles/daisyui.css`. The template includes light, dark, contrast, material, dim, and material-dark style themes. The light theme uses:

- Primary: `#167bff`
- Secondary: `#9c5de8`
- Accent: `#00d3bb`
- Success: `#0bbf58`
- Warning: `#f5a524`
- Error: `#f31260`

Do not hard-code one-off admin colors unless the template already does so for a specific semantic cue.

### Radius, Borders, Shadows

Theme radius values are compact: `--radius-field`, `--radius-box`, and `--radius-selector` are `0.25rem`. Use `rounded-box` rather than large rounded corners.

Borders use `border-base-300` or `border-base-200`. Dividers often use dashed borders, especially in the sidebar and search modal.

Common elevation:

- `shadow-sm` for standard cards and dropdowns
- `card-border` for bordered cards
- Material themes intentionally remove some card shadows and borders

### Density and Spacing

The dashboard is compact. Prefer:

- `mt-6` between page title and main content
- `gap-5` or `gap-6` for grids
- `px-5 pt-5` for card headers
- `p-5` or daisyUI default `card-body` padding
- Small controls: `btn-sm`, `input-sm`, `select-sm`, `checkbox-sm`

Avoid oversized marketing-style spacing in admin screens.

### Icons

Use Iconify with Lucide icons:

```html
<span class="iconify lucide--search size-4"></span>
```

Common sizes are `size-3.5`, `size-4`, `size-4.5`, and `size-5`.

## 10. Component Inventory

### Application Shell

Purpose: Shared admin frame with sidebar, sticky topbar, content area, footer, and rightbar.

Use for every authenticated admin page.

Key files: `src/starter.html`, `src/partials/sidebar.html`, `src/partials/topbar.html`, `src/partials/rightbar.html`.

### Sidebar

Purpose: Primary navigation.

Use grouped labels, direct links, daisyUI collapses, active `.menu-item`, and Lucide icons. New admin sections should be added here.

### Topbar

Purpose: Global tools.

Includes sidebar toggles, search modal, customization trigger, notifications, and profile UI. Keep business page-specific actions in page content, not in the topbar.

### Page Title

Purpose: Page identity and breadcrumbs.

Use simple title and hidden-on-mobile breadcrumbs for most CRUD pages. Rich title variants exist in component demos but should be selected only when the page needs actions, tabs, stats, or a progress indicator.

### Tables

Purpose: Record management and compact data display.

Use daisyUI `.table`, horizontal overflow wrappers, compact action buttons, semantic badges, and pagination footer.

### Cards

Purpose: Group dashboard widgets, form sections, detail sections, and settings sections.

Use `bg-base-100`, `shadow-sm`, `card-border`, `card-body`, and compact titles.

### Forms

Purpose: Create/edit resource records and settings.

Use `fieldset`, `fieldset-label`, daisyUI controls, responsive grids, full-width fields, and bottom-right action rows.

### Modals

Purpose: Focused confirmation or upload/edit flows.

Use native dialog with `modal`, `modal-box`, `modal-action`, and `modal-backdrop`.

### Drawers

Purpose: Side panels for profile, notifications, and customization.

Use daisyUI `drawer drawer-end` and checkbox triggers.

### Dropdowns

Purpose: Secondary actions and menus.

Use `dropdown dropdown-bottom dropdown-end`, `dropdown-content bg-base-100 rounded-box shadow-sm`, and daisyUI `menu`.

### Badges and Status

Purpose: Compact state display.

Use `badge-soft` for low-emphasis status, `badge-sm` in tables/cards, and semantic color classes.

### Tabs

Purpose: Small in-card switches.

Use `tabs tabs-box tabs-xs` for dashboard chart intervals and `tabs tabs-sm tabs-border` for notification-like panels.

### Search

Purpose: Local table search or global command/search modal.

Local search uses `label.input.input-sm` with `lucide--search`. Global search is a topbar modal with keyboard-hint footer and grouped results.

### Charts

Purpose: Dashboard visualization.

Use ApexCharts page scripts when charts are required. Chart cards use compact headers, optional tabs, large summary values, and chart container IDs.

## 11. Admin Page Recommendations

For Ca Heo DIY admin pages:

1. Use the standard Nexus shell for all admin pages.
2. Place admin routes under a single admin navigation group; products, categories, inventory, orders, customers, and content should not each invent their own navigation pattern.
3. Use the listing page pattern for product/category/order/customer management.
4. Use the form-card grid pattern for create/edit screens.
5. Use the detail page pattern for order and customer detail views.
6. Use dashboard stats cards and chart cards only on true overview pages.
7. Keep controls compact with `btn-sm`, `input-sm`, and `select-sm` where the template does.
8. Use daisyUI semantic colors and Nexus theme variables, not hard-coded color palettes.
9. Use Iconify Lucide icons for all admin icons.
10. Keep breadcrumbs visible on desktop and hidden on small screens.
11. Use `overflow-auto` around wide tables rather than compressing many columns into unreadable mobile layouts.
12. Use confirmation modals for destructive actions.
13. Use drawers for persistent secondary panels, not one-off confirmations.
14. Prefer `card bg-base-100 shadow-sm` for operational widgets and `card card-border bg-base-100` for detail/settings sections.
15. Keep admin UI dense, practical, and consistent with the Nexus dashboard rather than creating storefront or marketing-style layouts.

