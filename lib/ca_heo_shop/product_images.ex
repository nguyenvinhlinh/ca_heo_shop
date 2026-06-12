defmodule CaHeoShop.ProductImages do
  @moduledoc """
  The ProductImages context.
  """

  import Ecto.Query, warn: false
  alias CaHeoShop.Repo

  alias CaHeoShop.ProductImages.ProductImage
  alias CaHeoShop.Products.Product

  def list_product_images do
    Repo.all(ProductImage)
  end

  def list_product_images_for_product(%Product{id: product_id}) do
    list_product_images_for_product(product_id)
  end

  def list_product_images_for_product(product_id) do
    ProductImage
    |> where([image], image.product_id == ^product_id)
    |> order_by([image], asc: image.display_order, asc: image.id)
    |> Repo.all()
  end

  def get_product_image!(id), do: Repo.get!(ProductImage, id)

  def create_product_image(attrs \\ %{}) do
    %ProductImage{}
    |> ProductImage.changeset(attrs)
    |> Repo.insert()
  end

  def update_product_image(%ProductImage{} = product_image, attrs) do
    product_image
    |> ProductImage.changeset(attrs)
    |> Repo.update()
  end

  def delete_product_image(%ProductImage{} = product_image) do
    Repo.delete(product_image)
  end

  def change_product_image(%ProductImage{} = product_image, attrs \\ %{}) do
    ProductImage.changeset(product_image, attrs)
  end
end
