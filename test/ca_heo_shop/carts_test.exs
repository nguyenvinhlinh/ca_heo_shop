defmodule CaHeoShop.CartsTest do
  use CaHeoShop.DataCase

  alias CaHeoShop.Carts
  alias CaHeoShop.Carts.CartItem

  import CaHeoShop.AccountsFixtures
  import CaHeoShop.ProductsFixtures

  describe "cart_items" do
    test "change_cart_item/2 requires customer_id, product_variant_id, and quantity" do
      changeset = Carts.change_cart_item(%CartItem{}, %{})

      assert %{
               customer_id: ["can't be blank"],
               product_variant_id: ["can't be blank"],
               quantity: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "change_cart_item/2 validates positive quantity" do
      changeset =
        Carts.change_cart_item(%CartItem{}, %{
          customer_id: 1,
          product_variant_id: 1,
          quantity: 0
        })

      assert "must be greater than 0" in errors_on(changeset).quantity
    end

    test "add_cart_item/3 enforces unique customer and product_variant" do
      customer = user_fixture()
      product_variant = product_variant_fixture(product_fixture())

      assert {:ok, _cart_item} = Carts.add_cart_item(customer, product_variant, 1)
      assert {:ok, cart_item} = Carts.add_cart_item(customer, product_variant, 2)

      assert cart_item.quantity == 3
      assert Carts.list_cart_items(customer) == [cart_item]
    end

    test "add_cart_item/3 enforces customer foreign key" do
      product_variant = product_variant_fixture(product_fixture())

      assert {:error, changeset} = Carts.add_cart_item(-1, product_variant, 1)
      assert "does not exist" in errors_on(changeset).customer_id
    end

    test "add_cart_item/3 enforces product variant foreign key" do
      customer = user_fixture()

      assert {:error, changeset} = Carts.add_cart_item(customer, -1, 1)
      assert "does not exist" in errors_on(changeset).product_variant_id
    end

    test "update_cart_item_quantity/2 rejects quantities below one" do
      customer = user_fixture()
      product_variant = product_variant_fixture(product_fixture())
      {:ok, cart_item} = Carts.add_cart_item(customer, product_variant, 1)

      assert {:error, changeset} = Carts.update_cart_item_quantity(cart_item, 0)
      assert "must be greater than 0" in errors_on(changeset).quantity
    end

    test "clear_cart/1 deletes only the customer's items" do
      customer = user_fixture()
      other_customer = user_fixture()
      product_variant = product_variant_fixture(product_fixture())
      other_product_variant = product_variant_fixture(product_fixture(), %{variant_name: "Other"})

      {:ok, _cart_item} = Carts.add_cart_item(customer, product_variant, 1)
      {:ok, other_cart_item} = Carts.add_cart_item(other_customer, other_product_variant, 1)

      assert {1, nil} = Carts.clear_cart(customer)
      assert Carts.list_cart_items(customer) == []
      assert Carts.list_cart_items(other_customer) == [other_cart_item]
    end
  end
end
