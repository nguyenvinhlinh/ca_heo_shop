defmodule CaHeoShop.Carts do
  @moduledoc """
  The Carts context.
  """

  import Ecto.Query, warn: false
  alias CaHeoShop.Repo

  alias CaHeoShop.Accounts.User
  alias CaHeoShop.Carts.CartItem
  alias CaHeoShop.ProductVariants.ProductVariant

  def list_cart_items(%User{id: customer_id}) do
    list_cart_items(customer_id)
  end

  def list_cart_items(customer_id) do
    CartItem
    |> where([item], item.customer_id == ^customer_id)
    |> order_by([item], asc: item.id)
    |> Repo.all()
  end

  def get_cart_item!(id), do: Repo.get!(CartItem, id)

  def add_cart_item(customer, product_variant, quantity)
      when is_integer(quantity) and quantity > 0 do
    customer_id = id_from(customer)
    product_variant_id = id_from(product_variant)

    case Repo.get_by(CartItem,
           customer_id: customer_id,
           product_variant_id: product_variant_id
         ) do
      %CartItem{} = cart_item ->
        update_cart_item_quantity(cart_item, cart_item.quantity + quantity)

      nil ->
        %CartItem{}
        |> CartItem.changeset(%{
          customer_id: customer_id,
          product_variant_id: product_variant_id,
          quantity: quantity
        })
        |> Repo.insert()
    end
  end

  def add_cart_item(customer, product_variant, quantity) do
    %CartItem{}
    |> CartItem.changeset(%{
      customer_id: id_from(customer),
      product_variant_id: id_from(product_variant),
      quantity: quantity
    })
    |> Ecto.Changeset.add_error(:quantity, "must be greater than 0")
    |> then(&{:error, &1})
  end

  def update_cart_item_quantity(%CartItem{} = cart_item, quantity) do
    cart_item
    |> CartItem.changeset(%{quantity: quantity})
    |> Repo.update()
  end

  def delete_cart_item(%CartItem{} = cart_item) do
    Repo.delete(cart_item)
  end

  def clear_cart(%User{id: customer_id}) do
    clear_cart(customer_id)
  end

  def clear_cart(customer_id) do
    CartItem
    |> where([item], item.customer_id == ^customer_id)
    |> Repo.delete_all()
  end

  def change_cart_item(%CartItem{} = cart_item, attrs \\ %{}) do
    CartItem.changeset(cart_item, attrs)
  end

  defp id_from(%User{id: id}), do: id
  defp id_from(%ProductVariant{id: id}), do: id
  defp id_from(%{id: id}), do: id
  defp id_from(id), do: id
end
