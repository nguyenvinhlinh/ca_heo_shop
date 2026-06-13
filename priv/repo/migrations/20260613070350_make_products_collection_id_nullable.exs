defmodule CaHeoShop.Repo.Migrations.MakeProductsCollectionIdNullable do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE products ALTER COLUMN collection_id DROP NOT NULL"
  end

  def down do
    execute "ALTER TABLE products ALTER COLUMN collection_id SET NOT NULL"
  end
end
