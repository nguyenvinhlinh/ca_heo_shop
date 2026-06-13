defmodule CaHeoShop.Repo.Migrations.AlignProductVariantsWithProductsContext do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE product_variants DROP CONSTRAINT product_variants_product_id_fkey"

    execute """
    ALTER TABLE product_variants
    ADD CONSTRAINT product_variants_product_id_fkey
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
    """

    drop_if_exists unique_index(:product_variants, [:product_id, :variant_name])

    create unique_index(:product_variants, [:product_id, :variant_name],
             name: :product_variants_product_id_variant_name_index
           )

    drop_if_exists constraint(:product_variants, :production_cost_must_be_non_negative)
    drop_if_exists constraint(:product_variants, :selling_price_must_be_non_negative)
    drop_if_exists constraint(:product_variants, :stock_quantity_must_be_non_negative)
    drop_if_exists constraint(:product_variants, :display_order_must_be_non_negative)

    create constraint(:product_variants, :product_variants_production_cost_non_negative,
             check: "production_cost >= 0"
           )

    create constraint(:product_variants, :product_variants_selling_price_non_negative,
             check: "selling_price >= 0"
           )

    create constraint(:product_variants, :product_variants_stock_quantity_non_negative,
             check: "stock_quantity >= 0"
           )

    create constraint(:product_variants, :product_variants_display_order_non_negative,
             check: "display_order >= 0"
           )
  end

  def down do
    drop constraint(:product_variants, :product_variants_production_cost_non_negative)
    drop constraint(:product_variants, :product_variants_selling_price_non_negative)
    drop constraint(:product_variants, :product_variants_stock_quantity_non_negative)
    drop constraint(:product_variants, :product_variants_display_order_non_negative)

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

    drop index(:product_variants, [:product_id, :variant_name],
           name: :product_variants_product_id_variant_name_index
         )

    create unique_index(:product_variants, [:product_id, :variant_name])

    execute "ALTER TABLE product_variants DROP CONSTRAINT product_variants_product_id_fkey"

    execute """
    ALTER TABLE product_variants
    ADD CONSTRAINT product_variants_product_id_fkey
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
    """
  end
end
