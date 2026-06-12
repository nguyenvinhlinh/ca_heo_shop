defmodule CaHeoShop.ProductVariants.ProductVariant do
  use Ecto.Schema
  import Ecto.Changeset

  alias CaHeoShop.Products.Product

  schema "product_variants" do
    field :variant_name, :string
    field :production_cost, :integer
    field :selling_price, :integer
    field :stock_quantity, :integer
    field :image_filename, :string
    field :display_order, :integer

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
    |> unique_constraint(:variant_name, name: :product_variants_product_id_variant_name_index)
    |> foreign_key_constraint(:product_id)
    |> check_constraint(:production_cost, name: :production_cost_must_be_non_negative)
    |> check_constraint(:selling_price, name: :selling_price_must_be_non_negative)
    |> check_constraint(:stock_quantity, name: :stock_quantity_must_be_non_negative)
    |> check_constraint(:display_order, name: :display_order_must_be_non_negative)
  end
end
