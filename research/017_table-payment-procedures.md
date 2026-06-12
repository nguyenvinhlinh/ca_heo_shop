# Payment Procedures Table Research

## 1. Overview

This document proposes a first database shape for:

```text
payment_procedures
```

Payment procedures track order-related payment or refund workflow. They are not the financial ledger; actual money movement belongs to future `financial_transactions`.

## 2. Current UI Findings

Checkout has a payment method placeholder. Admin settings has a payment note. Admin orders show mock statuses such as `Paid`, but no payment detail page exists.

## 3. Meaning

Recommended relationship:

```text
sale_order has many payment_procedures
payment_procedure belongs to sale_order
```

Multiple procedures allow an inbound customer payment and later outbound refund.

## 4. Directions and Methods

Directions:

```text
inbound
outbound
```

Payment methods:

```text
bank_transfer
qr_transfer
cod
cash
manual
```

## 5. Status Recommendation

Inbound statuses:

```text
unpaid
pending_confirmation
paid
failed
cancelled
refunded
```

Outbound statuses:

```text
pending
approved
processing
paid
failed
cancelled
```

## 6. Proposed `payment_procedures` Table

Recommended fields:

```text
id
sale_order_id
return_procedure_id
financial_transaction_id
direction
payment_method
amount
status
reference
confirmed_by_id
confirmed_at
note
inserted_at
updated_at
```

First implementation can require `sale_order_id`, `direction`, `amount`, and `status`. `return_procedure_id` and `financial_transaction_id` can remain nullable/deferred.

## 7. Boundaries

`store_settings` may store reusable payment instructions. It must not store order-specific payment state.

`financial_transactions` records actual money movement and can be deferred until expense/refund/reconciliation tracking is needed.

## 8. Relationships

Recommended:

```text
payment_procedures.sale_order_id -> sale_orders.id
payment_procedures.return_procedure_id -> return_procedures.id
payment_procedures.financial_transaction_id -> financial_transactions.id
payment_procedures.confirmed_by_id -> users.id
```

## 9. Indexes and Constraints

Recommended:

```elixir
create index(:payment_procedures, [:sale_order_id])
create index(:payment_procedures, [:return_procedure_id])
create index(:payment_procedures, [:direction])
create index(:payment_procedures, [:status])
create constraint(:payment_procedures, :amount_non_negative, check: "amount >= 0")
```

## 10. Naming

Recommended:

```text
Table: payment_procedures
Schema: CaHeoShop.PaymentProcedures.PaymentProcedure
Context: CaHeoShop.PaymentProcedures
```

## 11. Open Questions

- Should the first version create one inbound payment procedure automatically with each sale order?
- Should outbound refund procedures be deferred until return management exists?
- Should `paid` require a linked `financial_transaction` later?

## 12. Final Recommendation

Use `payment_procedures` for payment/refund workflow state. Keep payment instructions in settings and actual ledger records in `financial_transactions`.
