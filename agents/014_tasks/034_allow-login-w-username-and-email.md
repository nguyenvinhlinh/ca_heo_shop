# Task 034: Allow Login With Email Or Username

## Filename

`034_allow_login_with_email_or_username.md`

## Goal

Update the login flow so users can log in with either:

```text
email
username
```

This task only changes login identity behavior.

This task must not implement:

```text
role-based authorization
admin permissions
system permissions
route guards
LiveView access control
```

Roles already exist from Task 033, but Task 034 should not use role for access control yet.

## Dependency

This task depends on Task 033.

Task 033 should already provide:

```text
users.email nullable
users.username nullable
users.role
users.fullname
users must have email OR username
unique partial index for email
unique partial index for username
```

Do not start this task before Task 033 is complete.

## Background

The current Phoenix auth flow likely logs in by email only.

Existing function may look like:

```elixir
get_user_by_email_and_password(email, password)
```

After Task 033, some internal accounts can have:

```text
email: nil
username: admin
```

So login must support username-based authentication.

## Scope

Implement changes in the existing Accounts and auth UI flow.

Likely files:

```text
lib/ca_heo_shop/accounts.ex
lib/ca_heo_shop/accounts/user.ex
lib/ca_heo_shop_web/live/user_login_live.ex
lib/ca_heo_shop_web/controllers/user_session_controller.ex
test/ca_heo_shop/accounts_test.exs
test/ca_heo_shop_web/controllers/user_session_controller_test.exs
test/ca_heo_shop_web/live/user_login_live_test.exs
```

Actual files may differ depending on the generated Phoenix auth structure.

Search the codebase for:

```text
get_user_by_email_and_password
email
user[email]
```

and update only the login-related parts.

## Do Not Change

Do not change these flows in this task:

```text
registration
email confirmation
password reset
email change
role authorization
admin dashboard access rules
customer access rules
```

Registration can still require email.

Password reset can still require email.

Email confirmation can still use email.

This task is only for normal password login.

## Accounts Context Requirements

Update:

```text
lib/ca_heo_shop/accounts.ex
```

Add a new function:

```elixir
def get_user_by_login_and_password(login, password)
```

Expected behavior:

```text
login can be email
login can be username
password must match
invalid login returns nil
invalid password returns nil
blank login returns nil
blank password returns nil
```

Recommended implementation shape:

```elixir
def get_user_by_login_and_password(login, password)
    when is_binary(login) and is_binary(password) do
  user = get_user_by_login(login)

  if User.valid_password?(user, password), do: user
end

def get_user_by_login_and_password(_, _), do: nil
```

Add helper:

```elixir
def get_user_by_login(login) when is_binary(login) do
  login = String.trim(login)

  if login == "" do
    nil
  else
    Repo.one(
      from u in User,
        where: u.email == ^login or u.username == ^login
    )
  end
end

def get_user_by_login(_), do: nil
```

Keep the existing function if other flows still use it:

```elixir
get_user_by_email_and_password(email, password)
```

It can either stay unchanged or delegate to the new function:

```elixir
def get_user_by_email_and_password(email, password) do
  get_user_by_login_and_password(email, password)
end
```

Do not remove old functions unless all references are safely updated.

## Login Form Requirements

Update the login form field from email-only to login identity.

Current form may have:

```heex
<.input field={@form[:email]} type="email" label="Email" required />
```

Change to something like:

```heex
<.input
  field={@form[:login]}
  type="text"
  label="Email or username"
  autocomplete="username"
  required
/>
```

Keep password field unchanged.

Keep remember-me behavior unchanged.

## Login Controller / LiveView Requirements

Update login params from:

```elixir
%{"email" => email, "password" => password}
```

to:

```elixir
%{"login" => login, "password" => password}
```

Use:

```elixir
Accounts.get_user_by_login_and_password(login, password)
```

instead of:

```elixir
Accounts.get_user_by_email_and_password(email, password)
```

Error message should be identity-neutral.

Use:

```text
Invalid login or password
```

Do not use:

```text
Invalid email or password
```

## UX Copy Requirements

Change visible login copy from email-only language to email-or-username language.

Examples:

```text
Email or username
Enter your email or username
Invalid login or password
```

Do not expose whether the login identity exists.

Avoid messages like:

```text
username not found
email not found
```

## Security Requirements

Do not reveal whether a given email or username exists.

Both of these should return the same generic error:

```text
wrong login
wrong password
```

Generic error:

```text
Invalid login or password
```

Do not implement role checks.

Do not redirect based on role yet.

Successful login behavior should remain the same as before.

## Username Matching

For this task, username login can use exact matching.

Example:

```text
username: admin
login: admin
```

Email matching can rely on the existing `citext` behavior if the database uses `citext`.

Do not add username case-insensitive behavior unless the existing Task 033 design already normalizes username.

## Tests

Add Accounts tests.

Test successful login by email:

```text
user with email can log in using email and password
```

Test successful login by username:

```text
user with username can log in using username and password
```

Test username-only user:

```text
user with nil email and username can log in using username
```

Test email-only user:

```text
user with email and nil username can log in using email
```

Test invalid login:

```text
unknown login returns nil
```

Test invalid password:

```text
valid login with wrong password returns nil
```

Test blank login:

```text
blank login returns nil
```

Test trimmed login:

```text
login with surrounding spaces still works
```

Example:

```elixir
assert Accounts.get_user_by_login_and_password(" admin ", "1234qwer")
```

Add web login tests.

Test login form renders:

```text
Email or username
```

Test user can submit email login.

Test user can submit username login.

Test invalid login shows:

```text
Invalid login or password
```

Do not test role redirects in this task.

## Seed Login Verification

Using seed accounts from Task 033, these should work after this task:

```text
login: admin
password: 1234qwer
```

```text
login: nguyenvinhlinh
password: 1234qwer
```

```text
login: customer_1@gmail.com
password: 1234qwer
```

Do not create new seed accounts in this task unless needed for tests.

## Acceptance Criteria

The task is complete when:

```text
mix test passes
login form says Email or username
login form accepts username
login form accepts email
system seed account can log in with username admin
admin seed account can log in with username nguyenvinhlinh
customer seed account can log in with email customer_1@gmail.com
wrong login shows generic error
wrong password shows generic error
registration flow still works as before
password reset flow still uses email
email confirmation flow still uses email
no role-based authorization is implemented
no permission logic is implemented
```

## Notes

Keep this task narrow.

Task 034 should only answer this question:

```text
Can a user log in with either email or username?
```

Future tasks can handle:

```text
role-based redirects after login
admin-only routes
system-only account management
customer account area
username registration
password reset by username
case-insensitive username login
```
