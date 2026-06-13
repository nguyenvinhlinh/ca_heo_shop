# Task 033: Add User Role, Username, Fullname, And Seed Accounts

## Filename

`033_add_user_role_username_fullname_and_seed_accounts.md`

## Goal

Extend the existing Phoenix authentication user model.

Add these fields to the existing `users` table:

```text
role
username
fullname
````

Also update the system so `email` can be nullable.

The system should support users that log in without email, especially internal `system` and `admin` accounts.

Supported role values:

```text
system
admin
customer
```

## Background

The app currently has Phoenix authentication tables:

```text
users
users_tokens
```

The existing user schema should remain:

```text
CaHeoShop.Accounts.User
```

The existing context should remain:

```text
CaHeoShop.Accounts
```

Do not create a new `Users` context.

This task extends the existing Accounts domain.

## Design Decision

`email` should be nullable.

`username` should be nullable.

But a user must have at least one login identity:

```text
email OR username
```

Recommended account identity rules:

```text
system account   -> can use username only
admin account    -> can use username only
customer account -> can use email, username optional
```

`fullname` is display information only.

Do not use `fullname` for authentication.

## Scope

Implement:

```text
priv/repo/migrations/*_add_role_username_fullname_to_users.exs
lib/ca_heo_shop/accounts/user.ex
lib/ca_heo_shop/accounts.ex
priv/repo/seeds.exs
test/ca_heo_shop/accounts_test.exs
```

Do not implement:

```text
admin authorization
route guards
LiveView access control
role management UI
username login form UI
password reset by username
system account UI
customer profile UI
```

Those should be handled in future tasks.

## Migration Requirements

Create a migration that alters the existing `users` table.

Update `email` to allow null:

```elixir
alter table(:users) do
  modify :email, :citext, null: true
end
```

Add fields:

```elixir
alter table(:users) do
  add :username, :string
  add :fullname, :string
  add :role, :string, null: false, default: "customer"
end
```

Drop the old email unique index if it does not support nullable email properly:

```elixir
drop_if_exists unique_index(:users, [:email])
```

Create partial unique index for email:

```elixir
create unique_index(:users, [:email],
         where: "email IS NOT NULL",
         name: :users_email_index
       )
```

Create partial unique index for username:

```elixir
create unique_index(:users, [:username],
         where: "username IS NOT NULL",
         name: :users_username_index
       )
```

Add constraint requiring either email or username:

```elixir
create constraint(:users, :users_must_have_email_or_username,
         check: "email IS NOT NULL OR username IS NOT NULL"
       )
```

Add role check constraint:

```elixir
create constraint(:users, :users_role_must_be_valid,
         check: "role IN ('system', 'admin', 'customer')"
       )
```

## Schema Requirements

Update:

```text
lib/ca_heo_shop/accounts/user.ex
```

Add fields:

```elixir
field :username, :string
field :fullname, :string
field :role, :string, default: "customer"
```

Add role helper:

```elixir
@roles ~w(system admin customer)

def roles, do: @roles
```

Add username validation helper:

```elixir
defp validate_username(changeset) do
  changeset
  |> validate_format(:username, ~r/^[a-zA-Z0-9_]+$/,
    message: "must contain only letters, numbers, and underscore"
  )
  |> validate_length(:username, min: 3, max: 32)
end
```

Only run username format and length validation when username is present.

Add fullname validation:

```elixir
validate_length(:fullname, max: 160)
```

Add role validation:

```elixir
validate_inclusion(:role, @roles)
```

Add constraints:

```elixir
unique_constraint(:email, name: :users_email_index)

unique_constraint(:username, name: :users_username_index)

check_constraint(:role, name: :users_role_must_be_valid)

check_constraint(:email, name: :users_must_have_email_or_username)
```

The `users_must_have_email_or_username` constraint may be attached to either `:email` or `:username` in the changeset.

## Public Registration Safety

Public registration must not allow the caller to set `role`.

A normal customer registration should always default to:

```text
role = customer
```

If the existing registration changeset casts attributes, do not blindly cast `:role`.

Recommended public registration fields:

```elixir
[
  :email,
  :password
]
```

Do not allow public registration to create:

```text
system
admin
```

Public customer registration should still require email for now.

Even though the database allows nullable email, the public customer registration flow should keep email required until a future task changes the login UX.

## Login Identity Requirement

Database-level rule:

```text
email OR username is required
```

Application-level behavior should match this rule.

Add a changeset validation helper if useful:

```elixir
defp validate_email_or_username(changeset) do
  email = get_field(changeset, :email)
  username = get_field(changeset, :username)

  if is_nil(email) and is_nil(username) do
    add_error(changeset, :email, "email or username is required")
  else
    changeset
  end
end
```

Use the database constraint as the final guard.

## Internal Seed Changeset

Add an internal seed changeset to support system/admin creation.

Example:

```elixir
def seed_changeset(user, attrs) do
  user
  |> cast(attrs, [:email, :username, :fullname, :role, :password, :confirmed_at])
  |> validate_required([:role, :password])
  |> validate_email_or_username()
  |> validate_email_if_present()
  |> validate_password()
  |> validate_username()
  |> validate_length(:fullname, max: 160)
  |> validate_inclusion(:role, @roles)
  |> maybe_hash_password()
  |> unique_constraint(:email, name: :users_email_index)
  |> unique_constraint(:username, name: :users_username_index)
  |> check_constraint(:role, name: :users_role_must_be_valid)
  |> check_constraint(:email, name: :users_must_have_email_or_username)
end
```

If the project already has reusable email/password helpers, reuse them.

Do not duplicate too much auth logic.

## Accounts Context Requirements

Update:

```text
lib/ca_heo_shop/accounts.ex
```

Add a helper for seed/internal user creation if needed:

```elixir
def create_seed_user(attrs) do
  %User{}
  |> User.seed_changeset(attrs)
  |> Repo.insert()
end
```

Also add an idempotent helper if preferred:

```elixir
def upsert_seed_user(attrs) do
  user =
    cond do
      attrs[:email] ->
        Repo.get_by(User, email: attrs[:email])

      attrs[:username] ->
        Repo.get_by(User, username: attrs[:username])

      true ->
        nil
    end

  (user || %User{})
  |> User.seed_changeset(attrs)
  |> Repo.insert_or_update()
end
```

Future login task may add:

```elixir
get_user_by_login_and_password(login, password)
```

But this task does not need to fully change the login form UI yet unless the current tests require it.

## Seed Requirements

Update:

```text
priv/repo/seeds.exs
```

Create development seed accounts.

These accounts are for local/dev use only.

Add a clear warning comment:

```elixir
# Development seed accounts only.
# Do not use these passwords in production.
```

### System Account

```text
role: system
username: admin
fullname: System Admin
email: nil
password: 1234qwer
```

### Admin Account

```text
role: admin
username: nguyenvinhlinh
fullname: Nguyễn Vĩnh Linh
email: nil
password: 1234qwer
```

### Customer Account

```text
role: customer
email: customer_1@gmail.com
username: nil
fullname: Customer 1
password: 1234qwer
```

Recommended seed shape:

```elixir
alias CaHeoShop.Accounts

# Development seed accounts only.
# Do not use these passwords in production.

Accounts.upsert_seed_user(%{
  email: nil,
  username: "admin",
  fullname: "System Admin",
  role: "system",
  password: "1234qwer",
  confirmed_at: DateTime.utc_now(:second)
})

Accounts.upsert_seed_user(%{
  email: nil,
  username: "nguyenvinhlinh",
  fullname: "Nguyễn Vĩnh Linh",
  role: "admin",
  password: "1234qwer",
  confirmed_at: DateTime.utc_now(:second)
})

Accounts.upsert_seed_user(%{
  email: "customer_1@gmail.com",
  username: nil,
  fullname: "Customer 1",
  role: "customer",
  password: "1234qwer",
  confirmed_at: DateTime.utc_now(:second)
})
```

Seeds must be idempotent.

Running this multiple times should not create duplicate users:

```bash
mix run priv/repo/seeds.exs
```

## Tests

Add tests for migration/schema behavior:

```text
users.email can be nil
users.username can be nil
users.fullname can be nil
users.role defaults to customer
user is invalid when both email and username are nil
user is valid when email exists and username is nil
user is valid when username exists and email is nil
user is valid when both email and username exist
```

Add tests for role:

```text
system role is accepted
admin role is accepted
customer role is accepted
invalid role is rejected
```

Add tests for username:

```text
username can be nil
username can be set
username must be unique when present
multiple users can have nil username
username rejects spaces
username rejects special characters
username rejects values shorter than 3 characters
username rejects values longer than 32 characters
```

Add tests for fullname:

```text
fullname can be nil
fullname can be set
fullname is not unique
fullname rejects values longer than 160 characters
```

Add tests for public registration safety:

```text
public registration defaults role to customer
public registration does not allow caller to create admin role
public registration does not allow caller to create system role
```

Add tests for seed/internal changeset:

```text
seed_changeset can create username-only system user
seed_changeset can create username-only admin user
seed_changeset can create email-based customer user
seed_changeset rejects user without email and username
```

## Acceptance Criteria

The task is complete when:

```text
mix ecto.migrate works
mix test passes
users.email is nullable
users.username exists
users.fullname exists
users.role exists
users.role defaults to customer
users.role only allows system, admin, customer
users.username is nullable
users.username is unique when not null
users.fullname is nullable
users.fullname is not unique
users must have at least email or username
public registration cannot set admin/system role
public customer registration still requires email
seed file creates username-only system account
seed file creates username-only admin account
seed file creates email-based customer account
seed file can run multiple times without duplicate users
```

## Notes

Keep this task focused on account data and seed data.

This task prepares the app for future role-based authorization.

Do not implement authorization in this task.

Future tasks can add:

```text
username login form
get_user_by_login_and_password/2
role-based route protection
admin-only LiveViews
system-only account management
admin user management UI
customer profile UI
```
