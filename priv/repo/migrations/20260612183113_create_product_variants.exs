defmodule CaHeoShop.Repo.Migrations.CreateProductVariants do
  use Ecto.Migration

  def change do
    create table(:product_variants) do
      add :product_id, references(:products, on_delete: :restrict), null: false
      add :variant_name, :string, null: false
      add :production_cost, :integer, null: false, default: 0
      add :selling_price, :integer, null: false
      add :stock_quantity, :integer, null: false, default: 0
      add :image_filename, :string
      add :display_order, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:product_variants, [:product_id])
    create index(:product_variants, [:product_id, :display_order])
    create unique_index(:product_variants, [:product_id, :variant_name])

    create constraint(:product_variants, :production_cost_must_be_non_negative,
             check: "production_cost >= 0"
           )

    create constraint(:product_variants, :selling_price_must_be_non_negative,
             check: "selling_price >= 0"
           )

    create constraint(:product_variants, :stock_quantity_must_be_non_negative,
             check: "stock_quantity >= 0"
           )

    create constraint(:product_variants, :display_order_must_be_non_negative,
             check: "display_order >= 0"
           )
  end
end
