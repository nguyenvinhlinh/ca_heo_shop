# Financial Transactions Table Research

## 1. Overview

This document proposes a future database shape for:

```text
financial_transactions
```

This table is a money ledger, not a payment workflow table. It should be deferred until the shop needs income/expense tracking, refunds, cash ledger, reconciliation, or reporting.

## 2. Use Cases

Examples:

```text
customer payment
refund
PLA/material purchase
shipping expense
tool expense
operating expense
other income
other expense
```

Do not force all financial transactions to belong to a sale order.

## 3. Direction and Type Values

Directions:

```text
inbound
outbound
```

Transaction types:

```text
customer_payment
refund
material_expense
shipping_expense
tool_expense
operating_expense
other_income
other_expense
```

## 4. Proposed `financial_transactions` Table

Recommended fields:

```text
id
direction
transaction_type
amount
occurred_at
payment_method
reference
related_type
related_id
created_by_id
note
inserted_at
updated_at
```

Use integer VND for `amount`.

## 5. Relationship Strategy

Polymorphic:

```text
related_type
related_id
```

is flexible for sale orders, payment procedures, returns, or expenses without direct order relation.

Explicit nullable fields are stricter but less flexible:

```text
sale_order_id
payment_procedure_id
return_procedure_id
```

Recommendation: defer final relationship strategy until the finance UI exists.

## 6. Constraints and Indexes

Recommended:

```elixir
create index(:financial_transactions, [:direction])
create index(:financial_transactions, [:transaction_type])
create index(:financial_transactions, [:occurred_at])
create index(:financial_transactions, [:related_type, :related_id])
create constraint(:financial_transactions, :amount_non_negative, check: "amount >= 0")
```

## 7. Naming

Recommended:

```text
Table: financial_transactions
Schema: CaHeoShop.Finance.FinancialTransaction
Context: CaHeoShop.Finance
```

## 8. Open Questions

- Should finance be part of `Sales` or separate `Finance` context?
- Should expenses be entered manually in admin?
- Should `occurred_at` be required or default to insertion time?
- Should transaction edits be audited?

## 9. Final Recommendation

Defer `financial_transactions`. When needed, design it as a standalone money ledger that can record both commerce-related and non-order expenses.
