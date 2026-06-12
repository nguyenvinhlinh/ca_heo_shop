# Store Settings Table Research

## 1. Overview

This document proposes a first database shape for global store settings.

Current `/admin/settings` is mock-only and shows contact information, shipping note, and payment note. This research does not implement settings persistence, payment behavior, checkout behavior, or migrations.

## 2. Current UI Findings

Admin settings mock fields:

```text
email
phone
shipping_note
payment_note
```

Mock data also contains `store_name` and `tagline`, but the visible settings form focuses on contact, shipping, and payment notes.

## 3. Commerce Flow Boundary

`store_settings` may provide reusable checkout display copy such as shipping/payment instructions.

It must not store:

```text
order-specific payment status
payment confirmation
payment reference
refund status
financial ledger records
```

Those belong to `payment_procedures` and `financial_transactions`.

## 4. Design Options

Recommended first option:

```text
single-row store_settings table with explicit columns
```

Reject key-value settings for now because it weakens typing and adds complexity before the admin UI needs dynamic settings.

## 5. Proposed `store_settings` Table

Recommended fields:

```text
id
singleton_key
contact_email
contact_phone
payment_note
shipping_note
inserted_at
updated_at
```

Defer:

```text
store_name
store_tagline
store_description
logo_filename
contact_address
bank_account_name
bank_account_number
bank_name
qr_payment_image_filename
cod_enabled
cash_enabled
default_shipping_fee
free_shipping_threshold
announcement_text
announcement_enabled
maintenance_mode_enabled
updated_by_id
```

## 6. Single-Row Strategy

Recommended:

```elixir
add :singleton_key, :boolean, null: false, default: true
create unique_index(:store_settings, [:singleton_key])
create constraint(:store_settings, :singleton_key_true, check: "singleton_key = true")
```

## 7. Naming

Recommended:

```text
Table: store_settings
Schema: CaHeoShop.StoreSettings.StoreSetting
Context: CaHeoShop.StoreSettings
```

## 8. Open Questions

- Should structured bank/QR display fields be added when checkout payment UI becomes real?
- Should store name/tagline remain static app copy or move into settings?
- Should settings changes be audited later?

## 9. Final Recommendation

Use a single-row explicit `store_settings` table with contact email, contact phone, payment note, and shipping note. Keep payment state and financial records out of settings.
