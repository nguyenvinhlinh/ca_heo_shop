defmodule CaHeoShop.Products.ProductVariant do
  use Ecto.Schema
  import Ecto.Changeset

  alias CaHeoShop.Products.Product

  schema "product_variants" do
    field :variant_name, :string
    field :production_cost, :integer, default: 0
    field :selling_price, :integer
    field :stock_quantity, :integer, default: 0
    field :image_filename, :string
    field :display_order, :integer, default: 0

    belongs_to :product, Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product_variant, attrs) do
    product_variant
    |> cast(attrs, [
      :product_id,
      :variant_name,
      :production_cost,
      :selling_price,
      :stock_quantity,
      :image_filename,
      :display_order
    ])
    |> validate_required([
      :product_id,
      :variant_name,
      :production_cost,
      :selling_price,
      :stock_quantity,
      :display_order
    ])
    |> validate_number(:production_cost, greater_than_or_equal_to: 0)
    |> validate_number(:selling_price, greater_than_or_equal_to: 0)
    |> validate_number(:stock_quantity, greater_than_or_equal_to: 0)
    |> validate_number(:display_order, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:product_id)
    |> unique_constraint(:variant_name,
      name: :product_variants_product_id_variant_name_index
    )
    |> check_constraint(:production_cost,
      name: :product_variants_production_cost_non_negative
    )
    |> check_constraint(:selling_price, name: :product_variants_selling_price_non_negative)
    |> check_constraint(:stock_quantity, name: :product_variants_stock_quantity_non_negative)
    |> check_constraint(:display_order, name: :product_variants_display_order_non_negative)
  end
end
