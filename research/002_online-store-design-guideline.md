# Online Store Design Guideline

## 1. Overview

The Online Store template is a Next.js 15 storefront built with TypeScript, React, Tailwind CSS v4, daisyUI v5, and Swiper. The source of truth is:

```text
/home/nguyenvinhlinh/Projects/ca_heo_shop/web_templates/online-store@2.0.0
```

The template is not a traditional full checkout storefront. It presents products, collections, filters, product detail pages, variants, related products, marketing sections, and external `Buy Now` links. There are no cart, checkout, order history, address management, or customer account routes/components in the inspected source.

Primary references inspected:

- `app/layout.tsx`
- `app/page.tsx`
- `app/collections/[slug]/layout.tsx`
- `app/collections/[slug]/page.tsx`
- `app/products/[slug]/layout.tsx`
- `app/products/[slug]/page.tsx`
- `app/about/page.tsx`
- `app/contact/page.tsx`
- `app/api/data/route.ts`
- `app/globals.css`
- `components/Header.tsx`
- `components/SideBar.tsx`
- `components/Footer.tsx`
- `components/Hero.tsx`
- `components/Features.tsx`
- `components/ProductCard.tsx`
- `components/ProductImage.tsx`
- `components/RelatedProducts.tsx`
- `components/SideFilter.tsx`
- `components/Categories.tsx`
- `components/CategoryCard.tsx`
- `components/OfferCard.tsx`
- `components/NewsLetter.tsx`
- `components/ThemeToggle.tsx`
- `context/ProductsContext.tsx`
- `hook/useProducts.ts`
- `data/site.ts`
- `data/sidebar.ts`
- `README.md`

For Ca Heo DIY customer-facing pages, reuse the template's visual language: large product photography, rounded image cards, simple daisyUI navigation, prominent collection/product pages, clear product prices, and low-friction purchase/contact entry points.

## 2. Storefront Layout Guidelines

The global storefront shell is defined in `app/layout.tsx`.

The layout structure is:

- `html lang="en"`
- `body` with `max-w-[120rem] mx-auto` and the Urbanist Google font
- `ProductsProvider`
- `Header`
- daisyUI `drawer` wrapping page content and mobile sidebar
- `Footer`

The body is capped at `120rem` and centered. Pages should use this global max width rather than adding a separate full-width application shell.

The primary horizontal spacing pattern is:

- `lg:px-14 px-5` for most storefront sections
- `lg:py-20 py-5` for simple content pages
- `py-10` for homepage sections
- `py-20` for the newsletter section

The header is a sticky daisyUI navbar:

```tsx
<div className="navbar md:px-10 bg-base-100/70 border-b-2 border-base-content/10 backdrop-blur-lg sticky z-30 top-0">
```

It contains:

- Mobile drawer toggle on the left, visible below `lg`
- Site title link
- Center desktop navigation using `menu menu-horizontal`
- Shop dropdown built with native `details`/`summary`
- Theme toggle on the right

The mobile navigation is a daisyUI drawer:

- Global drawer ID: `my-drawer-2`
- Sidebar width: `w-80`
- Background: `bg-base-200`
- Links use daisyUI `menu`
- Shop section is expanded by default with `<details open>`

The footer is a daisyUI footer:

- Top border: `border border-t border-base-content/10`
- Layout: `footer footer-vertical md:footer-horizontal`
- Spacing: `py-10 px-2 lg:px-14`
- Brand/copyright block
- Link groups from `footerData`
- Payment logos
- Bottom "Made with daisyUI" strip

Future storefront pages should keep the same shell and section spacing. Avoid introducing a separate customer layout unless the current header/footer cannot support the page.

## 3. Homepage Patterns

The homepage composition in `app/page.tsx` is:

1. `Hero`
2. `Features`
3. `TrendingProducts`
4. `Categories`
5. `OfferCard`
6. `NewArrivals`
7. `NewsLetter`

### Hero

`components/Hero.tsx` uses Swiper for a large image carousel.

Key characteristics:

- Section wrapper: `lg:py-5 lg:px-14`
- Carousel: `relative lg:rounded-3xl bg-black`
- Forced light theme inside the carousel with `data-theme="light"`
- Images: `w-full h-[28rem] md:h-[40rem] object-cover`
- Dark overlay: `absolute inset-0 bg-base-content/30`
- Text overlay positioned left: `left-5 md:left-10 lg:left-20`
- Badge above title
- Large title: `text-4xl md:text-5xl lg:text-[4rem] font-semibold`
- Supporting copy with `text-base-100/80`
- Rounded `Shop Now` button
- Circular previous/next controls at the top right

Use the hero pattern for primary collection or seasonal promotion pages when there is strong photography. Keep text over the image rather than splitting text and image into separate cards.

### Features

`components/Features.tsx` shows trust/service indicators.

Responsive behavior:

- Below `xl`: Swiper carousel in a bordered rounded container
- At `xl` and above: four horizontal feature cards with equal widths

Feature cards use:

- `border border-base-content/10`
- `p-10`
- `rounded-lg`
- Centered icon, title, and muted description
- Icon image with `w-12 h-12 bg-base-200 p-2 rounded-lg grayscale`

Use this section for shipping, payment, return, custom-order, warranty, or maker-service promises.

### Product Sections

Trending and new arrival sections share the same structure:

- Wrapper: `py-10 lg:px-14 px-5`
- Header row: `flex justify-between items-center`
- Heading: `text-2xl lg:text-4xl font-bold`
- Carousel navigation buttons: `btn btn-outline btn-circle btn-sm`
- Product carousel through `ProductCard`

Use this pattern for featured products, new products, best sellers, and custom picks.

### Categories

`components/Categories.tsx` and `CategoryCard.tsx` create a "Shop By Categories" section.

Responsive behavior:

- Below `xl`: horizontal daisyUI `carousel`
- At `xl` and above: flex row with image category cards

Category cards use:

- Large rounded image: `rounded-3xl`
- Button overlay near bottom: `absolute w-full bottom-10`
- Rounded category CTA: `btn btn-md rounded-full`

Use this pattern for 3D printed products, DIY kits, hydroponics/gardening, and custom orders.

### Offer Banner

`components/OfferCard.tsx` is a full-width promotional image banner.

Key characteristics:

- Image height: `h-[35rem]`
- `lg:rounded-3xl`
- Text block over bottom-left image
- Badge: `badge badge-sm ... bg-base-100/80 ... backdrop-blur-md`
- Large title: `text-3xl md:text-5xl font-semibold`
- Countdown using daisyUI `countdown`
- Dark CTA: `btn ... bg-base-content text-base-100`

Use only for real limited offers or major campaigns. The source's configured end date is data-driven in `data/site.ts`.

### Newsletter

`components/NewsLetter.tsx` uses another image-backed CTA.

Key characteristics:

- Image height: `h-[20rem] md:h-[25rem]`
- Dark overlay: `bg-base-content opacity-30`
- `data-theme="light"` inside overlay text
- Large white title and muted white copy
- Rounded daisyUI `input` with embedded Subscribe button

Use this for mailing-list signup or contact capture.

## 4. Product Listing Guidelines

Collection pages live under `app/collections/[slug]`.

The collection layout creates a title band:

- Height: `h-52`
- Centered column
- Bottom border: `border-b border-base-content/10`
- Title: `text-4xl md:text-5xl font-medium`
- Underline: `mx-auto w-24 h-px bg-base-content/30 mt-4`

The collection page then uses a daisyUI drawer for filters:

```tsx
<div className="drawer md:drawer-open">
    <input id="side-filter" type="checkbox" className="drawer-toggle" />
    <SideFilter ... />
    <div className="drawer-content flex flex-col">...</div>
</div>
```

Desktop filters are open by default from `md` upward. Mobile filters are opened by a `Filter By` button.

Listing controls:

- Mobile filter button: `btn w-28 border border-base-content/40 bg-transparent ... text-xs`
- Sort dropdown: `dropdown dropdown-end`
- Sort trigger: `btn px-5 lg:w-48 border border-base-content/20 bg-transparent`
- Sort options: Newer, Price low to high, Price high to low

Filtering logic is source-driven:

- Products are first filtered by collection slug in `attributes.category`
- Variant filters require selected values to match `attributes.variants`
- Price filter uses a max price range
- Sorting uses product ID for Newer and numeric parsed price for price order

Product grid layout is provided by `ProductCard`:

```tsx
<div className="grid md:grid-cols-2 xl:grid-cols-3 gap-6 mt-10">
```

Empty state is minimal:

```tsx
<p>No products found.</p>
```

Future listing pages should preserve the title band, filter drawer/sidebar, sorting dropdown, and ProductCard grid unless a specific customer need requires a narrower variation.

## 5. Product Detail Guidelines

Product details live under `app/products/[slug]`.

The page wrapper uses:

- `lg:px-14 px-5` from the product layout
- `pb-20`
- `mt-10`
- Main product grid: `flex flex-col lg:grid gap-6 lg:gap-12 lg:grid-cols-2`

### Product Image Gallery

`components/ProductImage.tsx` handles images.

Desktop behavior:

- If multiple images exist, display vertical thumbnail Swiper on the left
- Display large selected image on the right
- Thumbnail list uses vertical Swiper with four visible slides
- Selected thumbnail gets `border-2 border-base-content`
- Large image has hover zoom by setting background image, `backgroundSize: "200%"`, and making the foreground image fade on hover

Mobile behavior:

- Uses a horizontal Swiper with pagination
- Image is full width with rounded corners
- No vertical thumbnail rail

Use high-quality product images and preserve the image-first layout. Product inspection is a core part of the template.

### Product Information

Product information hierarchy:

- Product name: `text-3xl md:text-4xl mb-4 font-bold`
- Current price: `text-2xl lg:text-3xl font-semibold`
- Original price: `line-through text-lg lg:text-xl text-base-content/40`
- Discount badge: `badge bg-success/20 ... text-success`
- Tax note: `text-base-content/50`
- Divider before variants
- Variant radio controls
- Primary purchase button
- Product detail accordions
- Related product carousel

Purchase behavior:

- If `availability === false`, show disabled "Out of stock"
- If variants exist and none is selected, show disabled "Select a Variant"
- If variants exist and one is selected, use selected variant external link
- If no variants exist, use `attributes.buy_now_url`

The template uses external checkout links rather than an internal cart.

### Product Accordions

Product details use daisyUI `collapse collapse-arrow` blocks with borders:

- First accordion is Description and is open by default
- Additional accordions come from `attributes.info`
- Accordion body text is `text-sm text-base-content/60`

Use accordions for description, specifications, material, sizing, care, shipping notes, and maker/customization notes.

### Related Products

Related products are computed by shared category overlap and shown as `Explore more`.

Use:

- `mt-20 mb-28`
- Heading: `text-2xl lg:text-4xl font-semibold`
- Carousel navigation buttons
- `ProductCard` carousel named `related`

## 6. Shopping Cart Guidelines

The inspected source has no shopping cart route, cart component, cart context, cart drawer, quantity selector, or cart item layout.

The current template purchase model is:

- Product listing cards link to product details
- Product detail pages use `Buy Now`
- `Buy Now` opens an external LemonSqueezy/Gumroad/product variant link

For Ca Heo DIY, do not claim this template already defines a cart interaction pattern. If an internal cart is later added, keep it visually consistent with the source:

- Use the existing storefront shell, header, and footer
- Use daisyUI components and semantic colors
- Keep product thumbnails rounded
- Use clear pricing and quantity controls
- Preserve mobile-first drawer or single-column behavior

But this would be new implementation, not an observed template pattern.

## 7. Checkout Guidelines

The inspected source has no checkout pages, shipping forms, order summary, payment section, confirmation page, or internal payment flow.

Checkout is delegated externally through `attributes.buy_now_url` or selected variant links. Product data can come from LemonSqueezy, Gumroad, or local sample JSON, but the storefront does not implement checkout UI.

For future Ca Heo DIY work, this means:

- Source-consistent pages should use "Buy Now" or "Contact to Order" as the conversion action unless internal checkout is explicitly requested.
- An internal checkout flow would be a new pattern and should be designed deliberately, not inferred as already present.
- If added, it should reuse the template's spacing, daisyUI form controls, rounded product thumbnails, clear order totals, and simple one-column mobile layout.

## 8. Customer Account Guidelines

The inspected source has no customer account area.

There are no routes or components for:

- Account dashboard
- Login/register
- Profile management
- Address management
- Order history
- Saved payment methods

The only non-product customer information pages are content pages such as About, Contact, Terms, Privacy, and Cookies. `About` and `Contact` use a simple prose layout:

```tsx
<div className="lg:py-20 py-5 lg:px-14 mx-auto">
    <div className="prose">...</div>
</div>
```

If Ca Heo DIY later needs account pages, treat them as a new addition. Keep typography and shell consistent, but do not invent account conventions and present them as coming from this template.

## 9. Ecommerce Component Inventory

### Header

Purpose: Global storefront navigation, mobile drawer trigger, site title, collection links, shop dropdown, and theme toggle.

Reuse on all customer-facing pages.

### Mobile Sidebar

Purpose: Mobile navigation drawer.

Uses daisyUI `drawer-side`, `drawer-overlay`, and `menu`. It mirrors the navigation data from `data/sidebar.ts`.

### Footer

Purpose: Store information, collection links, content/legal links, payment badges, and daisyUI attribution.

Use for all storefront pages.

### Hero Carousel

Purpose: Primary homepage promotion.

Uses Swiper with image slides, overlay text, badge, CTA, pagination, autoplay, and circular arrow controls.

### Feature Cards

Purpose: Trust/service indicators.

Desktop uses bordered cards in a row. Smaller screens use a Swiper carousel.

### Product Card

Purpose: Product preview for carousels and grids.

Uses rounded product image, optional hover image swap, sale badge, glass-like bottom overlay, product name, price/original price, and small circular arrow button.

### Product Carousel

Purpose: Trending, new arrival, and related product sections.

Uses Swiper with responsive `slidesPerView`: 1.5 on small screens, 3 at 768px, 4 at 1440px.

### Product Grid

Purpose: Collection listing pages.

Uses `grid md:grid-cols-2 xl:grid-cols-3 gap-6 mt-10`.

### Category Card

Purpose: Collection entry points.

Uses rounded category image and bottom-centered rounded button. Mobile uses daisyUI carousel; desktop uses flex row.

### Side Filter

Purpose: Collection filtering.

Uses daisyUI drawer behavior, range input for max price, and checkbox filters generated from product variants.

### Sort Dropdown

Purpose: Collection ordering.

Uses daisyUI dropdown with menu options.

### Product Image Gallery

Purpose: Product inspection.

Desktop uses vertical thumbnail navigation and hover zoom. Mobile uses image Swiper with pagination.

### Product Variant Selector

Purpose: Select purchase variant before enabling Buy Now.

Uses radio inputs generated from `attributes.variants`.

### Product Detail Accordions

Purpose: Description and structured product information.

Uses daisyUI collapse groups with radio inputs.

### Offer Banner

Purpose: Promotional campaign.

Uses full image background, badge, title, countdown, and CTA.

### Newsletter Banner

Purpose: Email capture.

Uses image background, overlay, rounded input, and embedded subscribe button.

### Theme Toggle

Purpose: Light/dark theme switching.

Uses daisyUI `swap swap-rotate`, stores `theme` in localStorage, and writes `data-theme` to the document element.

### Prose Content Pages

Purpose: About, Contact, Terms, Privacy, Cookies.

Uses `prose` inside a padded page wrapper.

## 10. Mobile Experience Guidelines

The template is explicitly responsive.

Global mobile patterns:

- Header collapses navigation into a drawer below `lg`
- Storefront sections use `px-5` on mobile and `lg:px-14` on desktop
- Hero image height is reduced from `md:h-[40rem]` to `h-[28rem]`
- Homepage features become a carousel below `xl`
- Category cards become a horizontal carousel below `xl`
- Product carousel shows 1.5 slides from 320px width
- Collection filters become a drawer below `md`
- Collection products use one column by default, then two columns at `md`, three at `xl`
- Product detail switches from two-column desktop layout to stacked mobile layout
- Product image gallery switches from vertical thumbnails to mobile Swiper pagination

Mobile UX recommendations:

- Keep primary actions large and full width on product detail pages (`btn-block`)
- Keep filters hidden in a drawer until requested
- Preserve generous image sizes; do not shrink product images to tiny thumbnails
- Use carousels for horizontally browsable merchandising sections
- Avoid dense multi-column forms or tables on customer-facing mobile pages, since the source does not use them

## 11. Visual Design System

### Typography

The template uses the Urbanist Google font via `next/font/google`.

Common type hierarchy:

- Hero title: `text-4xl md:text-5xl lg:text-[4rem] font-semibold`
- Section title: `text-2xl lg:text-4xl font-bold`
- Product detail title: `text-3xl md:text-4xl font-bold`
- Product detail price: `text-2xl lg:text-3xl font-semibold`
- Collection title: `text-4xl md:text-5xl font-medium`
- Supporting copy: `text-sm md:text-lg`, often with `/70`, `/80`, or `/50` opacity

### Color

The template relies on daisyUI semantic theme colors:

- `bg-base-100`
- `bg-base-200`
- `text-base-content`
- `text-base-100` for text over dark hero/image overlays
- `text-error` for urgency in the offer banner
- `text-success` and `bg-success/20` for discount badges

Theme switching is controlled by `data-theme` on `<html>`.

### Shape and Radius

Product and marketing images use large rounded corners:

- `rounded-3xl` for hero, product cards, category cards, offer banner, and newsletter on desktop
- `rounded-lg` for feature cards and product detail image areas
- `rounded-full` for main CTAs and category buttons
- `rounded-2xl` for the product card overlay

### Product Image Presentation

Product visuals are the center of the template.

Patterns:

- Product cards show large images with rounded corners
- Secondary image fades in on hover if available
- Product card metadata sits in a translucent overlay at the bottom
- Product detail gallery supports thumbnail selection and zoom on desktop
- Mobile product detail uses swipeable image pagination

### Cards and Surfaces

The storefront does not use many traditional boxed cards. It prefers:

- Image cards
- Border-only trust cards
- Translucent overlays
- Rounded CTA surfaces
- Simple prose pages

Avoid converting the storefront into a card-heavy dashboard layout.

### Icons

The template mostly uses inline SVG icons rather than a shared icon library in components. Use simple line/arrow icons consistent with the existing style.

## 12. Conversion-Oriented Patterns

Observed conversion patterns:

- Large hero images with direct collection CTAs
- Homepage merchandising order: hero, trust indicators, trending products, categories, offer banner, new arrivals, newsletter
- Product cards show price directly on top of the image
- Sale badge appears on product image when `attributes.sale` is true
- Original price is struck through when present
- Product detail discount badge calculates percentage off
- Product detail `Buy Now` is full width and uses `btn-neutral btn-block`
- Disabled states explain blockers: "Out of stock" or "Select a Variant"
- Related products keep browsing momentum after product details
- Features communicate shipping, payment, returns, and freshness
- Offer banner uses a countdown to create urgency
- Newsletter captures interest after product discovery

Reuse strategy:

- Put product photography before explanatory text.
- Keep product prices visible on cards and detail pages.
- Keep purchase/contact action near variant selection.
- Use disabled button states to explain what the customer must do next.
- Use related products and category cards to prevent dead ends.
- For Ca Heo DIY custom products, replace generic discount language with practical maker-store promises such as made-to-order, custom sizing, material options, or contact-before-build.

## 13. Reusable UI Patterns

### Section Wrapper

Use `py-10 lg:px-14 px-5` for homepage merchandising sections.

### Section Header

Use `flex justify-between items-center` with `text-2xl lg:text-4xl font-bold` heading and optional circular navigation buttons.

### Image-Backed CTA

Use a full-width image, overlay, left-positioned text, badge, and rounded CTA. This appears in hero, offer, and newsletter sections.

### Product Card Overlay

Use a bottom overlay with `bg-base-100/80 backdrop-blur rounded-2xl shadow-sm px-4 lg:px-7 py-2`.

### Collection Header Band

Use `h-52`, centered title, bottom border, and a short horizontal rule.

### Filter Drawer

Use daisyUI drawer with `md:drawer-open`, range input, checkbox groups, and mobile-only filter button.

### Sort Menu

Use daisyUI dropdown/menu with transparent bordered button.

### Product Details Accordion

Use daisyUI `collapse collapse-arrow`, border, rounded corners, and radio inputs sharing the same group name.

### Prose Content Page

Use `lg:py-20 py-5 lg:px-14 mx-auto` and `prose` for informational pages.

## 14. Storefront Recommendations

For Ca Heo DIY customer-facing pages:

1. Keep the existing storefront shell: sticky navbar, mobile drawer, content, and footer.
2. Replace fashion categories with Ca Heo DIY categories: 3D printed products, DIY kits, hydroponics/gardening, and custom orders.
3. Preserve product-first browsing: large photos, visible price, clear product names, and direct detail links.
4. Use collection pages for product categories and product tags.
5. Keep filters simple: price and practical variants such as material, color, size, kit type, or availability.
6. Use product detail accordions for specifications, materials, print/build time, shipping, care, and custom-order notes.
7. Use "Buy Now", "Contact to Order", or "Request Customization" according to the actual ordering model.
8. Do not add cart, checkout, or customer account UI unless explicitly requested; those flows are not present in this template.
9. If internal checkout is added later, treat it as a new design task and reuse the template's existing typography, spacing, rounded product images, and daisyUI controls.
10. Keep homepage sections lightweight: hero, trust indicators, featured products, categories, one promotion/custom-order banner, new arrivals, and newsletter/contact capture.
11. Keep mobile pages image-rich and single-column where appropriate.
12. Avoid admin-style dense tables/cards on storefront pages.
13. Use daisyUI semantic colors and theme-aware classes.
14. Keep legal/about/contact pages simple with `prose`.
15. Base future storefront decisions on actual product data and customer ordering needs rather than adding generic enterprise ecommerce features.

