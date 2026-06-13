defmodule CaHeoShop.Repo.Migrations.AddHasThumbnailToCollections do
  use Ecto.Migration

  def change do
    alter table(:collections) do
      add :has_thumbnail, :boolean, default: nil, null: true
    end
  end
end
