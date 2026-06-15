defmodule CaHeoShop.Repo.Migrations.AddRoleUsernameFullnameToUsers do
  use Ecto.Migration

  def change do
    drop_if_exists unique_index(:users, [:email])

    alter table(:users) do
      modify :email, :citext, null: true
      add :username, :string
      add :fullname, :string
      add :role, :string, null: false, default: "customer"
    end

    create unique_index(:users, [:email],
             where: "email IS NOT NULL",
             name: :users_email_index
           )

    create unique_index(:users, [:username],
             where: "username IS NOT NULL",
             name: :users_username_index
           )

    create constraint(:users, :users_must_have_email_or_username,
             check: "email IS NOT NULL OR username IS NOT NULL"
           )

    create constraint(:users, :users_role_must_be_valid,
             check: "role IN ('system', 'admin', 'customer')"
           )
  end
end
