defmodule CaHeoShop.Catalog.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :name_vi, :string
    field :name_en, :string
    field :slug, :string
    field :description_vi, :string
    field :description_en, :string
    field :image_filename, :string
    field :nav_display_order, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [
      :name_vi,
      :name_en,
      :slug,
      :description_vi,
      :description_en,
      :image_filename,
      :nav_display_order
    ])
    |> validate_required([:name_vi, :name_en, :slug])
    |> validate_number(:nav_display_order, greater_than_or_equal_to: 0)
    |> unique_constraint(:slug)
    |> check_constraint(:nav_display_order, name: :nav_display_order_must_be_non_negative)
  end
end
