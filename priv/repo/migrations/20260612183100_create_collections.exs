defmodule CaHeoShop.Repo.Migrations.CreateCollections do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :name_vi, :string, null: false
      add :name_en, :string, null: false
      add :slug, :string, null: false
      add :description_vi, :text
      add :description_en, :text
      add :image_filename, :string
      add :nav_display_order, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:collections, [:slug])
    create index(:collections, [:nav_display_order])

    create constraint(:collections, :nav_display_order_must_be_non_negative,
             check: "nav_display_order IS NULL OR nav_display_order >= 0"
           )
  end
end
