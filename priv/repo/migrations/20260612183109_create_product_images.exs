defmodule CaHeoShop.Repo.Migrations.CreateProductImages do
  use Ecto.Migration

  def change do
    create table(:product_images) do
      add :product_id, references(:products, on_delete: :restrict), null: false
      add :filename, :string, null: false
      add :display_order, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:product_images, [:product_id])
    create index(:product_images, [:product_id, :display_order])

    create constraint(:product_images, :display_order_must_be_non_negative,
             check: "display_order >= 0"
           )
  end
end
