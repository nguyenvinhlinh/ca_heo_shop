defmodule CaHeoShop.Repo.Migrations.AddBilingualNamesToProductVariants do
  use Ecto.Migration

  def up do
    alter table(:product_variants) do
      add :variant_name_vi, :string
      add :variant_name_en, :string
    end

    flush()

    execute """
    UPDATE product_variants
    SET
      variant_name_vi = variant_name,
      variant_name_en = variant_name
    WHERE variant_name IS NOT NULL
    """

    flush()

    alter table(:product_variants) do
      modify :variant_name_vi, :string, null: false
      modify :variant_name_en, :string, null: false
    end

    create unique_index(:product_variants, [:product_id, :variant_name_vi],
             name: :product_variants_product_id_variant_name_vi_index
           )

    create unique_index(:product_variants, [:product_id, :variant_name_en],
             name: :product_variants_product_id_variant_name_en_index
           )
  end

  def down do
    drop index(:product_variants, [:product_id, :variant_name_en],
           name: :product_variants_product_id_variant_name_en_index
         )

    drop index(:product_variants, [:product_id, :variant_name_vi],
           name: :product_variants_product_id_variant_name_vi_index
         )

    alter table(:product_variants) do
      remove :variant_name_en
      remove :variant_name_vi
    end
  end
end
