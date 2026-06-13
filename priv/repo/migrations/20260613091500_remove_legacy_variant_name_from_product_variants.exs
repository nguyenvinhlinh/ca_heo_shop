defmodule CaHeoShop.Repo.Migrations.RemoveLegacyVariantNameFromProductVariants do
  use Ecto.Migration

  def up do
    drop index(:product_variants, [:product_id, :variant_name],
           name: :product_variants_product_id_variant_name_index
         )

    alter table(:product_variants) do
      remove :variant_name
    end
  end

  def down do
    alter table(:product_variants) do
      add :variant_name, :string
    end

    flush()

    execute """
    UPDATE product_variants
    SET variant_name = variant_name_vi
    WHERE variant_name_vi IS NOT NULL
    """

    alter table(:product_variants) do
      modify :variant_name, :string, null: false
    end

    create unique_index(:product_variants, [:product_id, :variant_name],
             name: :product_variants_product_id_variant_name_index
           )
  end
end
