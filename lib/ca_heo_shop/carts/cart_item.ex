defmodule CaHeoShop.Carts.CartItem do
  use Ecto.Schema
  import Ecto.Changeset

  alias CaHeoShop.Accounts.User
  alias CaHeoShop.Products.ProductVariant

  schema "cart_items" do
    field :quantity, :integer

    belongs_to :customer, User
    belongs_to :product_variant, ProductVariant

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart_item, attrs) do
    cart_item
    |> cast(attrs, [:customer_id, :product_variant_id, :quantity])
    |> validate_required([:customer_id, :product_variant_id, :quantity])
    |> validate_number(:quantity, greater_than: 0)
    |> unique_constraint(:product_variant_id,
      name: :cart_items_customer_id_product_variant_id_index
    )
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:product_variant_id)
    |> check_constraint(:quantity, name: :quantity_must_be_positive)
  end
end
