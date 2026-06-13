defmodule CaHeoShop.Products.ProductImage do
  use Ecto.Schema
  import Ecto.Changeset

  alias CaHeoShop.Products.Product

  schema "product_images" do
    field :filename, :string
    field :display_order, :integer, default: 0
    field :has_thumbnail, :boolean, default: false

    belongs_to :product, Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product_image, attrs) do
    product_image
    |> cast(attrs, [:product_id, :filename, :display_order, :has_thumbnail])
    |> validate_required([:product_id, :filename])
    |> validate_number(:display_order, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:product_id)
    |> check_constraint(:display_order, name: :display_order_must_be_non_negative)
  end
end
