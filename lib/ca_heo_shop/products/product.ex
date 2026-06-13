defmodule CaHeoShop.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  alias CaHeoShop.Collections.Collection
  alias CaHeoShop.Products.ProductImage

  schema "products" do
    field :slug, :string
    field :name_vi, :string
    field :name_en, :string
    field :description_vi, :string
    field :description_en, :string

    belongs_to :collection, Collection
    has_many :product_images, ProductImage

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:collection_id, :slug, :name_vi, :name_en, :description_vi, :description_en])
    |> validate_required([:slug, :name_vi, :name_en])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:collection_id)
  end
end
