defmodule CaHeoShop.Repo.Migrations.AddHasThumbnailToProductImages do
  use Ecto.Migration

  def up do
    alter table(:product_images) do
      add :has_thumbnail, :boolean, null: false, default: false
    end

    create index(:product_images, [:has_thumbnail])

    execute "ALTER TABLE product_images DROP CONSTRAINT product_images_product_id_fkey"

    execute """
    ALTER TABLE product_images
    ADD CONSTRAINT product_images_product_id_fkey
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
    """
  end

  def down do
    execute "ALTER TABLE product_images DROP CONSTRAINT product_images_product_id_fkey"

    execute """
    ALTER TABLE product_images
    ADD CONSTRAINT product_images_product_id_fkey
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
    """

    drop index(:product_images, [:has_thumbnail])

    alter table(:product_images) do
      remove :has_thumbnail
    end
  end
end
