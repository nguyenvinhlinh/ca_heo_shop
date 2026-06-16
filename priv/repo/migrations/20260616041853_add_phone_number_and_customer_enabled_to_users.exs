defmodule CaHeoShop.Repo.Migrations.AddPhoneNumberAndCustomerEnabledToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :phone_number, :string
      add :is_customer_enabled, :boolean, default: true, null: false
    end
  end
end
