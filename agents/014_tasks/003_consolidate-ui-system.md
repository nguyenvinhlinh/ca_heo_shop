# Task: Consolidate UI System

## Objective

Review and consolidate the findings from the UI research documents into a single project-level UI system document.

The goal is to create a concise and practical reference that future AI agents can use when implementing new pages and features.

The resulting document should focus on project conventions rather than research details.

---

## Inputs

Read and analyze:

```text
research/001_nexus-design-guideline.md
research/002_online-store-design-guideline.md
research/003_daisyui-design-guideline.md
```

These documents are considered the source material.

---

## Deliverable

Create:

```text
agents/015_ui-system.md
```

This document becomes the primary UI reference for future development.

---

## Purpose

Future AI agents should not need to repeatedly analyze template source code.

Instead, they should read:

```text
agents/015_ui-system.md
```

and understand:

* Which UI system to use
* Which design patterns to follow
* Which components to reuse
* Which layouts to prefer

---

## Required Sections

### Overview

Document:

* Available UI systems
* When each system should be used

Example topics:

* Admin interfaces
* Customer-facing interfaces

---

### Admin UI Guidelines

Summarize findings from:

```text
research/nexus-design-guideline.md
```

Document:

* Layout conventions
* Navigation conventions
* Table patterns
* Form patterns
* Dashboard patterns
* Component usage

The goal is not to duplicate the research document.

Summarize only the rules that future development should follow.

---

### Customer UI Guidelines

Summarize findings from:

```text
research/online-store-design-guideline.md
```

Document:

* Storefront layout conventions
* Homepage patterns
* Product page patterns
* Cart patterns
* Checkout patterns
* Account page patterns

Focus on implementation guidance.

---

### Component Reuse Strategy

Document:

* Which components should be reused
* When new components may be created
* Preferred component patterns

Prioritize consistency over originality.

---

### Responsive Design Guidelines

Document:

* Mobile-first expectations
* Responsive behavior requirements
* Common responsive patterns

---

### Visual Consistency Rules

Document:

* Typography expectations
* Spacing expectations
* Color usage expectations
* Component consistency expectations

Focus on practical rules.

---

### AI Agent Rules

Document explicit rules such as:

* Reuse existing template patterns first
* Do not redesign pages without a requirement
* Match neighboring pages
* Prefer consistency over creativity

These rules should be easy for future AI agents to follow.

---

## What To Exclude

Do not copy large sections from the research documents.

Do not include implementation details.

Do not include component source code.

Do not create a new design system.

Do not redesign existing templates.

---

## Success Criteria

After reading:

```text
agents/013_ui-system.md
```

an AI agent should be able to:

* Create a new admin page
* Create a new storefront page
* Create a new form
* Create a new table
* Create a new ecommerce page

while remaining consistent with the project's established UI conventions.

The document should be concise, practical, and significantly shorter than the source research documents.
