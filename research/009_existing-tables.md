# Current Database Tables Research

## 1. Overview

The current implemented application database contains only Phoenix authentication tables.

Implemented application tables:

```text
users
users_tokens
```

System table ignored:

```text
schema_migrations
```

Source migration:

```text
priv/repo/migrations/20260606030215_create_users_auth_tables.exs
```

## 2. `users`

Purpose: registered account identity and authentication credentials.

Schema/context:

```text
Schema: CaHeoShop.Accounts.User
Context: CaHeoShop.Accounts
Scope: CaHeoShop.Accounts.Scope
```

Fields:

```text
id
email
hashed_password
confirmed_at
inserted_at
updated_at
```

Notes:

- `email` is `citext`, required, unique.
- `hashed_password` is optional because auth supports token/login flows.
- `confirmed_at` is optional.
- timestamps use `utc_datetime`.

Constraint:

```elixir
create unique_index(:users, [:email])
```

## 3. `users_tokens`

Purpose: session, login, and email-change token storage.

Schema/context:

```text
Schema: CaHeoShop.Accounts.UserToken
Context: CaHeoShop.Accounts
```

Fields:

```text
id
user_id
token
context
sent_to
authenticated_at
inserted_at
```

Notes:

- `user_id` references `users.id` with `on_delete: :delete_all`.
- `token` is binary and required.
- `context` is string and required.
- `sent_to` is optional.
- `authenticated_at` is optional.
- There is no `updated_at`.

Indexes:

```elixir
create index(:users_tokens, [:user_id])
create unique_index(:users_tokens, [:context, :token])
```

## 4. Commerce Status

No commerce tables are implemented yet. The following are research proposals only until later implementation tasks create migrations/schemas/contexts:

```text
collections
products
product_variants
product_images
cart_items
sale_orders
sale_order_items
fulfillment_procedures
payment_procedures
return_procedures
return_items
recipients
store_settings
financial_transactions
procedure_status_logs
inventory_movements
```
