# Task: Research Online Store Template

## Objective

Analyze the Online Store template source code and extract reusable storefront design patterns, ecommerce flows, UI conventions, and component usage guidelines.

The purpose of this task is to create documentation that allows future AI agents to build customer-facing pages that remain visually and structurally consistent with the Online Store template.

The final output must be based on observations from the source code.

Do not generate implementation code.

---

## Source Location

Template source directory:

```text
/home/nguyenvinhlinh/Projects/ca_heo_shop/web_templates/online-store@2.0.0
```

This directory is the source of truth.

Research must be based on the actual template code.

Do not rely on assumptions, external examples, marketing screenshots, or generic ecommerce knowledge when the source code already provides an answer.

---

## Research Process

Before creating the final document:

1. Explore the entire template directory.
2. Identify layouts and page structures.
3. Identify reusable components.
4. Identify ecommerce-specific patterns.
5. Identify mobile-responsive behavior.
6. Extract recurring design conventions.
7. Generate a guideline document based on findings.

The final document should reflect what actually exists in the template.

---

## Areas To Analyze

### Global Layout

Document:

* Header structure
* Navigation structure
* Footer structure
* Content containers
* Responsive behavior

Questions:

* How is the storefront organized?
* How does the layout adapt to mobile devices?
* Which layout patterns should be reused?

---

### Homepage Patterns

Analyze:

* Hero sections
* Featured products
* Product collections
* Promotional sections
* Trust indicators
* Marketing sections

Document:

* Section hierarchy
* Visual priorities
* Reusable patterns

---

### Product Listing Pages

Analyze:

* Product grids
* Filters
* Search functionality
* Sorting controls
* Pagination

Document:

* Layout structure
* Product presentation patterns
* Reusable listing components

---

### Product Detail Pages

Analyze:

* Product image gallery
* Product information layout
* Product specifications
* Product pricing
* Product actions
* Related products

Document:

* Information hierarchy
* Layout structure
* Reusable patterns

---

### Shopping Cart

Analyze:

* Cart layout
* Cart item presentation
* Quantity controls
* Pricing summaries
* Checkout entry points

Document:

* Cart interaction patterns
* Reusable components
* Layout conventions

---

### Checkout Experience

Analyze:

* Checkout pages
* Shipping forms
* Order summaries
* Payment sections
* Confirmation pages

Document:

* Checkout flow
* User journey
* Conversion-oriented patterns

---

### Customer Account Area

Analyze:

* Account dashboard
* Order history
* Address management
* Profile management

Document:

* Layout structure
* Navigation patterns
* Reusable account components

---

### Ecommerce Components

Create an inventory of reusable components.

Examples:

* Product cards
* Product gallery
* Product carousel
* Category cards
* Cart widgets
* Checkout components
* Search components
* Promotional banners
* Rating displays
* Empty states

For each component:

* Purpose
* Usage
* Reusability notes

---

### Mobile Experience

Analyze:

* Mobile navigation
* Mobile product browsing
* Mobile cart interactions
* Mobile checkout flow

Document:

* Mobile-first patterns
* Responsive behavior
* Mobile UX recommendations

---

### Visual Design System

Document:

* Typography hierarchy
* Spacing conventions
* Color usage
* Product image presentation
* Card styling
* Visual hierarchy

Questions:

* What defines the visual identity of the Online Store template?
* Which visual patterns should future pages imitate?

---

### Conversion-Oriented Design

Identify patterns intended to support ecommerce conversion.

Examples:

* Product image prominence
* Pricing visibility
* Add-to-cart placement
* Trust indicators
* Product recommendations
* Checkout simplification

Document:

* Existing conversion patterns
* Recommended reuse strategy

---

## Deliverable

Create:

```text
research/002_online-store-design-guideline.md
```

---

## Expected Output Structure

The generated document should contain:

1. Overview
2. Storefront Layout Guidelines
3. Homepage Patterns
4. Product Listing Guidelines
5. Product Detail Guidelines
6. Shopping Cart Guidelines
7. Checkout Guidelines
8. Customer Account Guidelines
9. Ecommerce Component Inventory
10. Mobile Experience Guidelines
11. Visual Design System
12. Conversion-Oriented Patterns
13. Reusable UI Patterns
14. Storefront Recommendations

---

## Important Constraints

Do not redesign the template.

Do not introduce a new design system.

Do not replace existing design patterns.

Do not propose alternative ecommerce frameworks.

The goal is to understand and document the Online Store template so future development remains consistent with it.

---

## Success Criteria

After reading the generated document, an AI agent should be able to:

* Build a homepage
* Build a product listing page
* Build a product detail page
* Build a shopping cart page
* Build a checkout page
* Build a customer account page

while maintaining consistency with the Online Store template without needing to re-analyze the original source code.
