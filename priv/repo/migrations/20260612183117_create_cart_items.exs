defmodule CaHeoShop.Repo.Migrations.CreateCartItems do
  use Ecto.Migration

  def change do
    create table(:cart_items) do
      add :customer_id, references(:users, on_delete: :delete_all), null: false
      add :product_variant_id, references(:product_variants, on_delete: :restrict), null: false
      add :quantity, :integer, null: false, default: 1

      timestamps(type: :utc_datetime)
    end

    create index(:cart_items, [:customer_id])
    create index(:cart_items, [:product_variant_id])
    create unique_index(:cart_items, [:customer_id, :product_variant_id])

    create constraint(:cart_items, :quantity_must_be_positive, check: "quantity > 0")
  end
end
