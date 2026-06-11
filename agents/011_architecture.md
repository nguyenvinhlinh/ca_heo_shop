# Architecture

## Current Stage

The project is in an early development stage.

The business direction is clearer than the technical architecture.

Database schemas, contexts, and modules are expected to evolve as the project grows.

Do not assume that the current architecture is final.

---

## Architecture Philosophy

Follow standard Phoenix conventions.

Prefer:

* Phoenix contexts
* LiveView
* Ecto
* Simple modules
* Clear responsibilities

Avoid:

* Premature abstractions
* Complex architectures
* Microservices
* Over-engineering

---

## Directory Structure

The project follows the default Phoenix structure.

```text
lib/
├── ca_heo_diy/
└── ca_heo_diy_web/
```

Business logic belongs in:

```text
lib/ca_heo_diy/
```

Web and presentation logic belongs in:

```text
lib/ca_heo_diy_web/
```

---

## Context Design Principles

Contexts should emerge from business needs.

Do not create contexts before a clear business requirement exists.

Possible future contexts may include:

* Products
* Orders
* Customers
* Inventory
* Content

These are examples, not commitments.

---

## LiveView Strategy

Prefer LiveView-first development.

Use server-rendered interfaces whenever possible.

Avoid introducing frontend frameworks unless a clear requirement exists.

---

## UI Architecture

The project uses:

* DaisyUI
* Tailwind CSS
* Phoenix LiveView

Reuse existing components whenever possible.

Avoid creating duplicate UI patterns.

---

## Evolution Strategy

Build the simplest solution that satisfies the current requirement.

Refactor when patterns become clear.

Do not design for hypothetical future requirements.

The architecture should evolve together with the business.
