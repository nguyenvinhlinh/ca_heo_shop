# Procedure Status Logs Table Research

## 1. Overview

This document proposes a future audit table for procedure status changes:

```text
procedure_status_logs
```

It should answer who changed which procedure status, when, from what value, to what value, and why.

## 2. Procedures To Audit

Recommended:

```text
fulfillment_procedures.status
payment_procedures.status
return_procedures.status
```

## 3. Generic vs Focused Tables

Generic table:

```text
procedure_status_logs
```

Focused alternatives:

```text
fulfillment_procedure_status_logs
payment_procedure_status_logs
return_procedure_status_logs
```

Recommendation: use generic `procedure_status_logs` if all procedure tables share the same audit shape. Use focused tables only if implementation needs stricter foreign keys per procedure type.

## 4. Proposed `procedure_status_logs` Table

Recommended fields:

```text
id
procedure_type
procedure_id
from_status
to_status
changed_by_id
actor_type
note
metadata
inserted_at
```

No `updated_at` is needed if logs are append-only.

## 5. Actor Strategy

`changed_by_id` should reference `users.id` when a user performs the change.

For system-triggered changes:

```text
changed_by_id = NULL
actor_type = system
```

For admin/customer changes:

```text
actor_type = admin
actor_type = customer
```

## 6. Append-Only Rule

Logs should not be edited through normal admin workflows. If a note is wrong, add another log entry rather than rewriting history.

## 7. Constraints and Indexes

Recommended:

```elixir
create index(:procedure_status_logs, [:procedure_type, :procedure_id])
create index(:procedure_status_logs, [:changed_by_id])
create index(:procedure_status_logs, [:inserted_at])
```

Consider `from_status != to_status` as an application validation.

## 8. Naming

Recommended:

```text
Table: procedure_status_logs
Schema: CaHeoShop.ProcedureStatusLogs.ProcedureStatusLog
Context: CaHeoShop.ProcedureStatusLogs
```

## 9. Open Questions

- Should the app require an audit log for every status transition?
- Should `metadata` be JSON/map or deferred?
- Should focused log tables be used for stronger foreign keys?

## 10. Final Recommendation

Use append-only `procedure_status_logs` when procedure status changes become real. Defer implementation until fulfillment/payment procedure persistence exists.
