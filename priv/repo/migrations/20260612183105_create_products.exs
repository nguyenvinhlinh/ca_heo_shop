defmodule CaHeoShop.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :collection_id, references(:collections, on_delete: :restrict), null: false
      add :slug, :string, null: false
      add :name_vi, :string, null: false
      add :name_en, :string, null: false
      add :description_vi, :text
      add :description_en, :text

      timestamps(type: :utc_datetime)
    end

    create index(:products, [:collection_id])
    create unique_index(:products, [:slug])
  end
end
