defmodule CaHeoShop.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias CaHeoShop.Repo

  alias CaHeoShop.Accounts.{User, UserToken, UserNotifier}

  @customer_default_page 1
  @customer_default_page_size 25
  @customer_supported_page_sizes [25, 50, 100]

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    get_user_by_login_and_password(email, password)
  end

  def get_user_by_login(login) when is_binary(login) do
    login = String.trim(login)

    if login == "" do
      nil
    else
      Repo.one(from u in User, where: u.email == ^login or u.username == ^login)
    end
  end

  def get_user_by_login(_), do: nil

  def get_user_by_login_and_password(login, password)
      when is_binary(login) and is_binary(password) do
    user = get_user_by_login(login)

    if login_allowed?(user) and User.valid_password?(user, password), do: user
  end

  def get_user_by_login_and_password(_, _), do: nil

  def list_customers(params \\ %{}) do
    params = normalize_customer_index_params(params)

    base_query =
      User
      |> where([user], user.role == "customer")
      |> customer_enabled_query(params.enabled)
      |> customer_search_query(params.q)

    total_count = Repo.aggregate(base_query, :count, :id)
    total_pages = max(Integer.ceil_div(total_count, params.page_size), 1)
    page = min(params.page, total_pages)

    entries =
      base_query
      |> order_by([user], desc: user.inserted_at, desc: user.id)
      |> limit(^params.page_size)
      |> offset(^((page - 1) * params.page_size))
      |> Repo.all()

    build_customer_index(entries, params, total_count, page, total_pages)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def create_seed_user(attrs) do
    %User{}
    |> User.seed_changeset(attrs)
    |> Repo.insert()
  end

  def upsert_seed_user(attrs) do
    attrs = Enum.into(attrs, %{})

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

  ## Settings

  @doc """
  Checks whether the user is in sudo mode.

  The user is in sudo mode when the last authentication was done no further
  than 20 minutes ago. The limit can be given as second argument in minutes.
  """
  def sudo_mode?(user, minutes \\ -20)

  def sudo_mode?(%User{authenticated_at: ts}, minutes) when is_struct(ts, DateTime) do
    DateTime.after?(ts, DateTime.utc_now() |> DateTime.add(minutes, :minute))
  end

  def sudo_mode?(_user, _minutes), do: false

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  See `CaHeoShop.Accounts.User.email_changeset/3` for a list of supported options.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}, opts \\ []) do
    User.email_changeset(user, attrs, opts)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    Repo.transact(fn ->
      with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
           %UserToken{sent_to: email} <- Repo.one(query),
           {:ok, user} <- Repo.update(User.email_changeset(user, %{email: email})),
           {_count, _result} <-
             Repo.delete_all(from(UserToken, where: [user_id: ^user.id, context: ^context])) do
        {:ok, user}
      else
        _ -> {:error, :transaction_aborted}
      end
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  See `CaHeoShop.Accounts.User.password_changeset/3` for a list of supported options.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}, opts \\ []) do
    User.password_changeset(user, attrs, opts)
  end

  @doc """
  Updates the user password.

  Returns a tuple with the updated user, as well as a list of expired tokens.

  ## Examples

      iex> update_user_password(user, %{password: ...})
      {:ok, {%User{}, [...]}}

      iex> update_user_password(user, %{password: "too short"})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> update_user_and_delete_all_tokens()
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.

  If the token is valid `{user, token_inserted_at}` is returned, otherwise `nil` is returned.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Gets the user with the given magic link token.
  """
  def get_user_by_magic_link_token(token) do
    with {:ok, query} <- UserToken.verify_magic_link_token_query(token),
         {user, _token} <- Repo.one(query),
         true <- login_allowed?(user) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Logs the user in by magic link.

  There are three cases to consider:

  1. The user has already confirmed their email. They are logged in
     and the magic link is expired.

  2. The user has not confirmed their email and no password is set.
     In this case, the user gets confirmed, logged in, and all tokens -
     including session ones - are expired. In theory, no other tokens
     exist but we delete all of them for best security practices.

  3. The user has not confirmed their email but a password is set.
     This cannot happen in the default implementation but may be the
     source of security pitfalls. See the "Mixing magic link and password registration" section of
     `mix help phx.gen.auth`.
  """
  def login_user_by_magic_link(token) do
    {:ok, query} = UserToken.verify_magic_link_token_query(token)

    case Repo.one(query) do
      # Prevent session fixation attacks by disallowing magic links for unconfirmed users with password
      {%User{confirmed_at: nil, hashed_password: hash}, _token} when not is_nil(hash) ->
        raise """
        magic link log in is not allowed for unconfirmed users with a password set!

        This cannot happen with the default implementation, which indicates that you
        might have adapted the code to a different use case. Please make sure to read the
        "Mixing magic link and password registration" section of `mix help phx.gen.auth`.
        """

      {%User{confirmed_at: nil} = user, _token} ->
        if login_allowed?(user) do
          user
          |> User.confirm_changeset()
          |> update_user_and_delete_all_tokens()
        else
          {:error, :not_found}
        end

      {user, token} ->
        if login_allowed?(user) do
          Repo.delete!(token)
          {:ok, {user, []}}
        else
          {:error, :not_found}
        end

      nil ->
        {:error, :not_found}

      _ ->
        {:error, :not_found}
    end
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm-email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Delivers the magic link login instructions to the given user.
  """
  def deliver_login_instructions(%User{} = user, magic_link_url_fun)
      when is_function(magic_link_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "login")
    Repo.insert!(user_token)
    UserNotifier.deliver_login_instructions(user, magic_link_url_fun.(encoded_token))
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(from(UserToken, where: [token: ^token, context: "session"]))
    :ok
  end

  ## Token helper

  defp update_user_and_delete_all_tokens(changeset) do
    Repo.transact(fn ->
      with {:ok, user} <- Repo.update(changeset) do
        tokens_to_expire = Repo.all_by(UserToken, user_id: user.id)

        Repo.delete_all(from(t in UserToken, where: t.id in ^Enum.map(tokens_to_expire, & &1.id)))

        {:ok, {user, tokens_to_expire}}
      end
    end)
  end

  defp login_allowed?(%User{role: "customer", is_customer_enabled: false}), do: false
  defp login_allowed?(%User{}), do: true
  defp login_allowed?(_user), do: false

  defp normalize_customer_index_params(params) do
    %{
      enabled:
        normalize_customer_enabled_filter(Map.get(params, "enabled") || Map.get(params, :enabled)),
      q: normalize_customer_query(Map.get(params, "q") || Map.get(params, :q)),
      page:
        normalize_positive_integer(
          Map.get(params, "page") || Map.get(params, :page),
          @customer_default_page
        ),
      page_size:
        normalize_supported_page_size(
          Map.get(params, "page_size") || Map.get(params, :page_size),
          @customer_default_page_size
        )
    }
  end

  defp normalize_customer_enabled_filter(value) when value in ["true", true], do: "true"
  defp normalize_customer_enabled_filter(value) when value in ["false", false], do: "false"
  defp normalize_customer_enabled_filter(_value), do: "all"

  defp normalize_customer_query(value) when is_binary(value), do: String.trim(value)
  defp normalize_customer_query(_value), do: ""

  defp normalize_positive_integer(value, _default) when is_integer(value) and value > 0, do: value

  defp normalize_positive_integer(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {parsed, ""} when parsed > 0 -> parsed
      _ -> default
    end
  end

  defp normalize_positive_integer(_value, default), do: default

  defp normalize_supported_page_size(value, default) do
    page_size = normalize_positive_integer(value, default)

    if page_size in @customer_supported_page_sizes do
      page_size
    else
      default
    end
  end

  defp customer_enabled_query(query, "true"),
    do: where(query, [user], user.is_customer_enabled == true)

  defp customer_enabled_query(query, "false"),
    do: where(query, [user], user.is_customer_enabled == false)

  defp customer_enabled_query(query, _enabled), do: query

  defp customer_search_query(query, ""), do: query

  defp customer_search_query(query, q) do
    pattern = "%#{q}%"

    where(
      query,
      [user],
      ilike(fragment("coalesce(?, '')", user.fullname), ^pattern) or
        ilike(fragment("coalesce(?, '')", user.email), ^pattern)
    )
  end

  defp build_customer_index(entries, params, total_count, page, total_pages) do
    {from, to} =
      case entries do
        [] ->
          {0, 0}

        _entries ->
          from = (page - 1) * params.page_size + 1
          {from, from + length(entries) - 1}
      end

    %{
      entries: entries,
      page: page,
      page_size: params.page_size,
      total_count: total_count,
      total_pages: total_pages,
      from: from,
      to: to,
      enabled: params.enabled,
      q: params.q
    }
  end
end
