# Task: Research Nexus Dashboard Template

## Source Location

The Nexus Dashboard template source code is located at:

```text
/home/nguyenvinhlinh/Projects/ca_heo_shop/web_templates/nexus-html@4.0.0
```


## Objective

Analyze the Nexus Dashboard template codebase and extract reusable UI patterns, layouts, components, and design conventions.

The purpose of this research is to enable future AI agents to generate new admin pages that are visually and structurally consistent with the existing Nexus Dashboard template.

The final output should be a design guideline document rather than implementation code.

---


## Background

Ca Heo DIY uses:

* Nexus Dashboard for administrator interfaces
* Online Store template for customer-facing interfaces

This task focuses only on the Nexus Dashboard template.

Future admin pages should reuse existing Nexus Dashboard patterns whenever possible.

---

## Scope

Analyze the entire Nexus Dashboard codebase and identify:

### Layout Patterns

Document:

* Main application layout
* Sidebar structure
* Header structure
* Content area organization
* Responsive behavior

Questions to answer:

* How are dashboard pages organized?
* How does navigation work?
* How does the layout behave on mobile devices?

---

### Navigation Patterns

Document:

* Sidebar navigation
* Top navigation
* Breadcrumbs
* Navigation groups
* Active menu states

Questions to answer:

* How should new admin sections be added?
* What navigation patterns should be reused?

---

### Page Patterns

Identify common page types:

Examples:

* Dashboard pages
* Listing pages
* Detail pages
* Settings pages
* Analytics pages

For each page type, document:

* Layout structure
* Common UI sections
* Recommended usage

---

### Table Patterns

Document:

* Data tables
* Search controls
* Filters
* Pagination
* Bulk actions
* Row actions

Questions to answer:

* How should management pages display records?
* Which table patterns should be reused?

---

### Form Patterns

Document:

* Form layouts
* Input groups
* Validation feedback
* Action buttons
* Multi-column layouts

Questions to answer:

* How should create/edit forms be structured?
* Which form components should be reused?

---

### Card Patterns

Document:

* Summary cards
* Statistics cards
* Information cards
* Action cards

Questions to answer:

* When should cards be used?
* What card layouts already exist?

---

### Modal Patterns

Document:

* Dialog usage
* Confirmation dialogs
* Action dialogs

Questions to answer:

* When are modals used?
* What modal conventions exist?

---

### Visual Design System

Document:

* Typography hierarchy
* Spacing conventions
* Color usage
* Border radius usage
* Shadows
* Visual density

Questions to answer:

* What visual characteristics define Nexus Dashboard?
* What should new pages imitate?

---

### Component Inventory

Create an inventory of reusable components.

Examples:

* Tables
* Cards
* Forms
* Navigation
* Modals
* Badges
* Alerts
* Tabs

For each component:

* Purpose
* Typical usage
* Reusability notes

---

## Deliverable

Create:

```text
research/001_nexus-design-guideline.md
```

---

## Expected Output Structure

The generated document should contain:

1. Overview
2. Layout Guidelines
3. Navigation Guidelines
4. Page Patterns
5. Table Patterns
6. Form Patterns
7. Card Patterns
8. Modal Patterns
9. Visual Design System
10. Component Inventory
11. Admin Page Recommendations

---

## Important Constraints

Do not redesign the template.

Do not create a new design system.

Do not propose alternative dashboard frameworks.

The goal is to understand and document the existing Nexus Dashboard design language.

Future admin pages should follow Nexus Dashboard conventions as closely as possible.

---

## Success Criteria

After reading the generated guideline document, an AI agent should be able to:

* Create a new admin page
* Create a new admin form
* Create a new admin table
* Create a new admin dashboard widget

while remaining visually consistent with the Nexus Dashboard template.
