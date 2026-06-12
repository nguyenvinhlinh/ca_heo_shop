## Change 3: Remove General Preferences Section from Admin Settings

On the admin settings page:

```text
/admin/settings
```

Remove the settings section named:

```text
General preferences
```

This section should be removed entirely.

Do not rename it.

Do not replace it with another settings section.

If the section contains inputs, toggles, placeholders, or mock values, remove the whole section and its related UI.

---

## Updated Success Criteria

The task is complete when:

* `/admin` no longer shows a search box.
* No `/admin/*` page shows a search box.
* `/admin/settings` no longer shows `Store information`.
* `/admin/settings` no longer shows `Public-facing store identity`.
* `/admin/settings` no longer shows `Store name`.
* `/admin/settings` no longer shows `Tagline`.
* `/admin/settings` no longer shows `General preferences`.
* The general shop/store information settings section is removed entirely.
* The general preferences settings section is removed entirely.
* The affected pages remain visually consistent with the Nexus Dashboard style.
* All data remains mock data only.
* No database changes are made.
* No Ecto schemas are created.
* No Ecto contexts are created.
* No Repo queries are added.
* The app compiles successfully.
* `mix format` has been run.
* `mix precommit` passes if available.
