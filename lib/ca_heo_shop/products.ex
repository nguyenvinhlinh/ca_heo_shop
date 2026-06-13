defmodule CaHeoShop.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias CaHeoShop.Repo

  alias CaHeoShop.Collections.Collection
  alias CaHeoShop.Products.Product
  alias CaHeoShop.Products.ProductImage
  alias CaHeoShop.Products.ProductVariant

  @admin_default_page 1
  @admin_default_per_page 20
  @admin_supported_per_page [20, 50, 100]

  def list_products do
    Repo.all(Product)
  end

  def list_admin_products(params \\ %{}) do
    params = normalize_admin_product_params(params)

    base_query =
      Product
      |> admin_product_search_query(params.q)
      |> admin_product_collection_query(params.collection)

    total_count = Repo.aggregate(base_query, :count, :id)
    total_pages = max(Integer.ceil_div(total_count, params.per_page), 1)
    page = min(params.page, total_pages)

    entries =
      base_query
      |> order_by([product], desc: product.inserted_at, desc: product.id)
      |> limit(^params.per_page)
      |> offset(^((page - 1) * params.per_page))
      |> preload([
        :collection,
        product_images: ^product_images_order_query(),
        product_variants: ^product_variants_order_query()
      ])
      |> Repo.all()

    build_admin_product_page(entries, params, total_count, page, total_pages)
  end

  def list_products_by_collection(%Collection{id: collection_id}) do
    list_products_by_collection(collection_id)
  end

  def list_products_by_collection(collection_id) do
    Product
    |> where([p], p.collection_id == ^collection_id)
    |> order_by([p], asc: p.name_vi)
    |> Repo.all()
  end

  def list_uncategorized_products do
    Product
    |> where([p], is_nil(p.collection_id))
    |> order_by([p], asc: p.name_vi)
    |> Repo.all()
  end

  def list_product_images(%Product{id: product_id}) do
    list_product_images(product_id)
  end

  def list_product_images(product_id) do
    ProductImage
    |> where([image], image.product_id == ^product_id)
    |> order_by([image], asc: image.display_order, asc: image.id)
    |> Repo.all()
  end

  def list_product_images_without_thumbnail do
    ProductImage
    |> where([image], image.has_thumbnail == false)
    |> order_by([image], asc: image.id)
    |> Repo.all()
  end

  def list_product_variants(%Product{id: product_id}) do
    list_product_variants(product_id)
  end

  def list_product_variants(product_id) do
    ProductVariant
    |> where([variant], variant.product_id == ^product_id)
    |> order_by([variant], asc: variant.display_order, asc: variant.inserted_at)
    |> Repo.all()
  end

  def get_product!(id), do: Repo.get!(Product, id)
  def get_product_image!(id), do: Repo.get!(ProductImage, id)
  def get_product_variant!(id), do: Repo.get!(ProductVariant, id)

  def get_admin_product!(id) do
    Product
    |> Repo.get!(id)
    |> Repo.preload([
      :collection,
      product_variants: product_variants_order_query(),
      product_images: product_images_order_query()
    ])
  end

  def get_product_by_slug!(slug) when is_binary(slug) do
    Repo.get_by!(Product, slug: slug)
  end

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def create_product_image(attrs \\ %{}) do
    %ProductImage{}
    |> ProductImage.changeset(attrs)
    |> Repo.insert()
  end

  def create_product_variant(attrs \\ %{}) do
    %ProductVariant{}
    |> ProductVariant.changeset(attrs)
    |> Repo.insert()
  end

  def create_product_image_for_product(%Product{id: product_id}, attrs \\ %{}) do
    attrs =
      attrs
      |> Map.new()
      |> Map.put(:product_id, product_id)

    create_product_image(attrs)
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def update_product_image(%ProductImage{} = product_image, attrs) do
    product_image
    |> ProductImage.changeset(attrs)
    |> Repo.update()
  end

  def update_product_variant(%ProductVariant{} = product_variant, attrs) do
    product_variant
    |> ProductVariant.changeset(attrs)
    |> Repo.update()
  end

  def mark_product_image_thumbnail_created(%ProductImage{} = product_image) do
    update_product_image(product_image, %{has_thumbnail: true})
  end

  def mark_product_image_thumbnail_missing(%ProductImage{} = product_image) do
    update_product_image(product_image, %{has_thumbnail: false})
  end

  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  def delete_product_image(%ProductImage{} = product_image) do
    Repo.delete(product_image)
  end

  def delete_product_variant(%ProductVariant{} = product_variant) do
    Repo.delete(product_variant)
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  def change_product_image(%ProductImage{} = product_image, attrs \\ %{}) do
    ProductImage.changeset(product_image, attrs)
  end

  def change_product_variant(%ProductVariant{} = product_variant, attrs \\ %{}) do
    ProductVariant.changeset(product_variant, attrs)
  end

  defp normalize_admin_product_params(params) do
    %{
      page:
        normalize_positive_integer(
          Map.get(params, "page") || Map.get(params, :page),
          @admin_default_page
        ),
      per_page:
        normalize_supported_per_page(
          Map.get(params, "per_page") || Map.get(params, :per_page),
          @admin_default_per_page
        ),
      collection:
        normalize_collection_filter(Map.get(params, "collection") || Map.get(params, :collection)),
      q: normalize_search_query(Map.get(params, "q") || Map.get(params, :q))
    }
  end

  defp normalize_positive_integer(value, _default) when is_integer(value) and value >= 1,
    do: value

  defp normalize_positive_integer(value, default) when is_integer(value), do: default

  defp normalize_positive_integer(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {parsed, ""} when parsed >= 1 -> parsed
      _other -> default
    end
  end

  defp normalize_positive_integer(_value, default), do: default

  defp normalize_supported_per_page(value, default) do
    per_page = normalize_positive_integer(value, default)

    if per_page in @admin_supported_per_page do
      per_page
    else
      default
    end
  end

  defp normalize_collection_filter(nil), do: "ALL"

  defp normalize_collection_filter(value) when is_binary(value) do
    value = String.trim(value)

    cond do
      value == "" -> "ALL"
      value == "ALL" -> "ALL"
      value == "NULL" -> "NULL"
      true -> value
    end
  end

  defp normalize_collection_filter(value), do: to_string(value)

  defp normalize_search_query(nil), do: ""
  defp normalize_search_query(value), do: value |> to_string() |> String.trim()

  defp admin_product_search_query(query, ""), do: query

  defp admin_product_search_query(query, q) do
    pattern = "%#{q}%"

    from product in query,
      where: ilike(product.name_vi, ^pattern) or ilike(product.name_en, ^pattern)
  end

  defp admin_product_collection_query(query, "ALL"), do: query

  defp admin_product_collection_query(query, "NULL") do
    from product in query, where: is_nil(product.collection_id)
  end

  defp admin_product_collection_query(query, collection_id) do
    case Integer.parse(to_string(collection_id)) do
      {parsed_id, ""} ->
        from product in query, where: product.collection_id == ^parsed_id

      _other ->
        query
    end
  end

  defp product_images_order_query do
    from product_image in ProductImage,
      order_by: [asc: product_image.display_order, asc: product_image.inserted_at]
  end

  defp product_variants_order_query do
    from product_variant in ProductVariant,
      order_by: [asc: product_variant.display_order, asc: product_variant.inserted_at]
  end

  defp build_admin_product_page(entries, params, total_count, page, total_pages) do
    {from, to} =
      if total_count == 0 do
        {0, 0}
      else
        from = (page - 1) * params.per_page + 1
        {from, from + length(entries) - 1}
      end

    %{
      entries: entries,
      page: page,
      per_page: params.per_page,
      total_count: total_count,
      total_pages: total_pages,
      from: from,
      to: to,
      collection: params.collection,
      q: params.q
    }
  end
end
