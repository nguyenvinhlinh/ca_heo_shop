# Project UI System

## Overview

Ca Heo DIY uses two UI systems:

- Admin UI: follow the Nexus Dashboard patterns documented in `research/001_nexus-design-guideline.md`.
- Customer UI: follow the Online Store patterns documented in `research/002_online-store-design-guideline.md`.

daisyUI and Tailwind CSS are the shared foundation. Use daisyUI components and semantic colors before creating custom UI. Keep the project simple, mobile-friendly, and product-focused.

Use the admin system for administrator workflows such as products, categories, inventory, orders, customers, and site content.

Use the customer system for storefront pages such as homepage, collections, product details, contact, legal pages, and customer-facing order flows.

## Admin UI Guidelines

Admin pages should feel like Nexus Dashboard: compact, operational, and structured.

Layout:

- Use the Nexus admin shell pattern: sidebar, sticky topbar, content area, footer, and optional rightbar/customization drawer.
- Put page content inside the main content container with responsive padding equivalent to `p-3 sm:p-4 md:p-6`.
- Use page title plus breadcrumbs on desktop. Hide breadcrumbs on small screens.
- Keep admin pages dense and scannable. Avoid storefront-style hero sections in admin areas.

Navigation:

- Use a sidebar as the primary admin navigation.
- Group related links. Product, category, inventory, order, and customer pages belong in ecommerce/admin navigation groups.
- Use simple active states and expandable groups where needed.
- Keep topbar actions global: search, account, theme/settings, notifications. Put page-specific actions inside the page.

Tables:

- Use daisyUI `table` inside an `overflow-auto` wrapper.
- Use compact row actions with small icon buttons.
- Use checkboxes for bulk selection when bulk actions exist.
- Use semantic badges or text colors for status.
- Use pagination controls and per-page selectors for long lists.

Forms:

- Use card-based form sections.
- Use daisyUI inputs, selects, textareas, toggles, checkboxes, radios, and fieldsets.
- Use responsive grids for related fields and full-width fields for long text.
- Put cancel/save actions at the bottom right.
- Use destructive actions only with clear confirmation.

Dashboards:

- Use stat cards, chart cards, tables, and compact list widgets.
- Use dashboards only for overview pages, not for CRUD screens.
- Keep controls small and focused.

Components:

- Prefer Nexus-style cards: `bg-base-100`, `shadow-sm`, or `card-border`.
- Use modals for confirmations and focused short tasks.
- Use drawers for persistent side panels.
- Use dropdowns for secondary actions.
- Use tabs only when they reduce page switching or clarify a small view mode.

## Customer UI Guidelines

Customer pages should feel like the Online Store template: image-led, simple, mobile-first, and conversion-oriented.

Storefront layout:

- Use the sticky navbar, mobile drawer navigation, page content, and footer pattern.
- Use generous horizontal spacing: small screens use narrow padding; desktop uses wide section padding.
- Keep footer links organized into collections, pages, and legal groups.
- Keep theme behavior daisyUI-compatible.

Homepage:

- Preferred order: hero, trust/features, featured products, categories, promotion/custom-order banner, new arrivals, newsletter/contact capture.
- Use real product or workshop imagery where possible.
- Use image-backed CTAs for important campaigns or custom-order messaging.
- Use category cards for 3D printed products, DIY kits, hydroponics/gardening, and custom orders.

Product listings:

- Use collection header bands with clear titles.
- Use a filter drawer/sidebar for mobile/desktop filtering.
- Use simple filters: price, material, color, size, kit type, availability, or category-specific variants.
- Use sorting dropdowns only for useful sort orders.
- Use product grids with large image cards.

Product details:

- Lead with product images.
- Use a two-column desktop layout and stacked mobile layout.
- Show product name, price, original price if relevant, sale/discount state, and availability clearly.
- Use variant radios or equivalent controls before enabling purchase.
- Use full-width primary purchase/contact buttons.
- Use accordions for description, specifications, materials, build/print time, shipping, care, and customization notes.
- Show related products to continue browsing.

Cart, checkout, and account:

- The Online Store template does not include internal cart, checkout, or customer account flows.
- Do not imply these patterns already exist.
- If internal cart, checkout, or account pages are requested, treat them as new design work while preserving the storefront typography, spacing, rounded product images, daisyUI controls, and simple mobile layout.
- Until internal checkout is explicitly required, prefer direct actions such as `Buy Now`, `Contact to Order`, or `Request Customization`.

Content pages:

- Use simple prose pages for About, Contact, Terms, Privacy, and Cookies.
- Keep copy readable and focused on customer trust.

## Component Reuse Strategy

Reuse existing patterns first:

- Admin: Nexus shell, sidebar, topbar, page titles, tables, cards, forms, modals, drawers, dropdowns, badges, tabs, search, and chart containers.
- Customer: storefront header, mobile drawer, footer, hero carousel, feature cards, product cards, product grids/carousels, category cards, side filters, sort dropdowns, product image gallery, detail accordions, offer banner, newsletter banner, and prose page wrapper.

Create a new component only when:

- No existing component matches the required behavior.
- Repeating the same markup would create meaningful duplication.
- The new component can be named around a real business concept.
- It preserves the visual language of its area.

Do not create new styling systems, custom component libraries, or one-off abstractions before the need is clear.

## Responsive Design Guidelines

Mobile support is required for all customer-facing pages and expected for admin pages.

Common rules:

- Design mobile-first, then expand layout at `md`, `lg`, and `xl`.
- Use drawers for navigation and filters on smaller screens.
- Use one-column content on mobile and grids on larger screens.
- Keep wide admin tables horizontally scrollable with `overflow-auto`.
- Hide secondary desktop-only content such as breadcrumbs when space is tight.
- Keep primary mobile actions obvious and tappable.
- Preserve product image size and clarity on mobile.

Admin responsive patterns:

- Sidebar collapses or overlays on small screens.
- Topbar remains sticky.
- Tables scroll horizontally.
- Form grids collapse to one column.

Customer responsive patterns:

- Header navigation moves into a drawer below desktop.
- Product and category carousels are acceptable for mobile merchandising.
- Product detail pages stack image gallery above product information.
- Listing filters use a drawer below desktop/tablet sizes.

## Visual Consistency Rules

Typography:

- Admin uses compact headings and dense text hierarchy.
- Customer pages use larger storefront section headings and image-led hierarchy.
- Keep font sizes tied to the surrounding layout. Do not use hero-scale type inside admin cards or compact panels.

Spacing:

- Admin spacing should be tight and operational.
- Customer spacing should be generous but not marketing-heavy beyond storefront sections.
- Use consistent section padding and grid gaps from neighboring pages.

Color:

- Prefer daisyUI semantic colors: `base-*`, `base-content`, `primary`, `secondary`, `accent`, `success`, `warning`, `error`, and `info`.
- Avoid hard-coded color palettes unless matching an existing template pattern.
- Use `primary` for the most important action, not every action.
- Preserve theme compatibility.

Shape and surfaces:

- Admin uses compact `rounded-box`, subtle borders, and `shadow-sm`.
- Customer uses rounded product imagery, image overlays, rounded CTAs, and simple bordered feature cards.
- Do not mix admin dashboard cards into storefront pages.
- Do not put storefront hero/banner patterns into admin CRUD screens.

Icons:

- Admin icons should follow the Nexus/Iconify Lucide style where applicable.
- Customer icons should remain simple and consistent with existing inline icon usage.
- Prefer familiar icon buttons for compact actions.

## AI Agent Rules

- Read this file before implementing UI.
- Use the admin UI system for admin pages and the customer UI system for storefront pages.
- Reuse existing template patterns before creating new patterns.
- Match neighboring pages in layout, spacing, components, and tone.
- Prefer consistency over originality.
- Do not redesign pages without an explicit requirement.
- Do not introduce cart, checkout, account, marketplace, loyalty, affiliate, social, livestream, ERP, or enterprise patterns unless explicitly requested.
- Keep Ca Heo DIY small-business needs in mind: simple catalog, product clarity, direct ordering, easy maintenance.
- Use daisyUI and Tailwind CSS classes; avoid custom CSS unless the existing patterns cannot express the need.
- Use semantic daisyUI colors to preserve theme compatibility.
- Keep mobile usability as a first-class requirement.
- For Phoenix LiveView, follow Phoenix conventions and use existing project components where available.
- If a route requires authentication, place it in the correct authenticated router scope and explain why.
- When unsure, choose the simpler pattern that already exists in the relevant UI system.

