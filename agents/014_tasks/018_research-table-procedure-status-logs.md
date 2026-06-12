# Task 018: Research Procedure Status Logs Database Schema

## Objective

Research the procedure status audit table proposed by `research/004-commerce-order-flow.md`, then propose a database schema for:

```text
procedure_status_logs
```

This task is research only. Do not create migrations, Ecto schemas, Ecto contexts, Repo queries, seeds, tests, real audit behavior, or status transition behavior.

## Deliverable

Create:

```text
research/020_table-procedure-status-logs.md
```

## Required Reading

Before starting, read:

```text
AGENTS.md
agents/001_phoenix-agent.md
agents/010_business-context.md
agents/011_architecture.md
agents/012_database-model.md
agents/013_ui-system.md
agents/014_task-workflow.md
research/004-commerce-order-flow.md
research/016_table-fulfillment-procedures.md
research/017_table-payment-procedures.md
research/018_table-return-procedures-return-items.md
```

If any procedure research file is missing, document that clearly.

## Scope

Research:

```text
procedure_status_logs
```

Status changes that should eventually be logged:

```text
fulfillment_procedures.status
payment_procedures.status
return_procedures.status
```

## Fields To Evaluate

Evaluate:

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

Also evaluate whether a generic `procedure_status_logs` table is better than focused tables such as:

```text
fulfillment_procedure_status_logs
payment_procedure_status_logs
return_procedure_status_logs
```

## Rules To Research

Document:

* Logs should be append-only.
* Logs should not be edited through normal admin workflows.
* `changed_by_id` should reference `users.id` when a user performs the change.
* System-triggered changes need a representation, either nullable `changed_by_id` plus `actor_type` or a dedicated system actor.

## Expected Output Structure

The file should contain:

1. Overview
2. Current UI Findings
3. Audit Log Meaning
4. Procedures To Audit
5. Generic vs Focused Log Table
6. Proposed `procedure_status_logs` Table
7. Field-by-Field Explanation
8. Actor Strategy
9. Append-Only Recommendation
10. Indexes and Constraints
11. Recommended Schema/Context Naming
12. Optional or Deferred Fields
13. Open Questions
14. Final Recommendation

## Success Criteria

The task is complete when:

* `research/020_table-procedure-status-logs.md` is created.
* The audit strategy can answer who changed what and when.
* Generic vs focused log table tradeoffs are documented.
* Append-only behavior is recommended.
* No production behavior or database implementation is created.
