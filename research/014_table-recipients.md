# Recipients Table Research

## 1. Overview

This document proposes a first database shape for saved delivery recipients.

Current checkout/account address behavior is mock-only. This research does not implement recipient CRUD, checkout behavior, order creation, or migrations.

## 2. Current UI Findings

Checkout asks for name, phone, email, address, city, and note. Account settings shows an address placeholder and edit button. Admin customers show customer name, email, phone, last order, and location.

## 3. Commerce Flow Requirement

`research/004-commerce-order-flow.md` requires recipient information to be snapshotted into `sale_orders` at checkout. Saved recipient records may change later; historical orders must keep checkout-time delivery data.

Guest checkout is deferred.

## 4. Proposed `recipients` Table

Recommended fields:

```text
id
customer_id
name
address
phone_number
is_default
inserted_at
updated_at
```

Use correct spelling:

```text
recipients
```

Do not use misspelled `recipents`.

## 5. Field Notes

- `customer_id`: references `users.id`, required.
- `name`: delivery recipient name, required.
- `address`: free-form text address, required.
- `phone_number`: string, required.
- `is_default`: boolean, required, default `false`.

Use a single `address` text field first. Defer structured address fields until shipping rates, geographic filtering, or carrier integrations require them.

## 6. Relationship to Sale Orders

Saved recipients are reusable customer address book records. Sale orders should copy recipient data into snapshot fields:

```text
recipient_fullname
recipient_phone_number
recipient_address
```

An optional future `sale_orders.recipient_id` can record provenance, but snapshots remain the historical source.

## 7. Constraints and Indexes

Recommended:

```elixir
create index(:recipients, [:customer_id])
create unique_index(:recipients, [:customer_id],
  where: "is_default = true",
  name: :recipients_one_default_per_customer_index)
```

Use `on_delete: :delete_all` for `customer_id` because saved recipients are account data. Sale order snapshots preserve history.

## 8. Naming

Recommended:

```text
Table: recipients
Schema: CaHeoShop.Customers.Recipient
Context: CaHeoShop.Customers
```

## 9. Open Questions

- Should checkout implement saved recipient selection before or after first real order creation?
- Should a customer be required to have one default recipient?
- Should structured address fields be introduced for Vietnam-specific delivery later?

## 10. Final Recommendation

Create a simple `recipients` proposal with `customer_id`, `name`, `address`, `phone_number`, and `is_default`. Keep sale order snapshots separate.
