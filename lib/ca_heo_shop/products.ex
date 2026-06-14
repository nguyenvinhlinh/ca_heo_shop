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
  alias Ecto.Multi

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

  def next_product_variant_display_order(%Product{id: product_id}) do
    next_product_variant_display_order(product_id)
  end

  def next_product_variant_display_order(product_id) do
    ProductVariant
    |> where([variant], variant.product_id == ^product_id)
    |> select([variant], max(variant.display_order))
    |> Repo.one()
    |> case do
      nil -> 0
      display_order -> display_order + 1
    end
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

  def update_product_summary(%Product{} = product, attrs) do
    product
    |> Product.summary_changeset(attrs)
    |> Repo.update()
  end

  def update_product_content(%Product{} = product, attrs) do
    product
    |> Product.content_changeset(attrs)
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

  def reorder_product_images(product_id, ordered_image_ids) when is_list(ordered_image_ids) do
    product_images = list_product_images(product_id)

    with {:ok, normalized_ids} <- normalize_product_image_ids(ordered_image_ids),
         :ok <- validate_product_image_order(product_images, normalized_ids) do
      product_images_by_id = Map.new(product_images, &{&1.id, &1})

      normalized_ids
      |> Enum.with_index()
      |> Enum.reduce(Multi.new(), fn {image_id, display_order}, multi ->
        Multi.update(
          multi,
          {:product_image, image_id},
          ProductImage.changeset(product_images_by_id[image_id], %{display_order: display_order})
        )
      end)
      |> Multi.run(:product_images, fn repo, _changes ->
        {:ok,
         product_id
         |> ordered_product_images_query()
         |> repo.all()}
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{product_images: reordered_product_images}} -> {:ok, reordered_product_images}
        {:error, _operation, _reason, _changes} -> {:error, :could_not_reorder_product_images}
      end
    end
  end

  def reorder_product_images(_product_id, _ordered_image_ids),
    do: {:error, :invalid_product_image_order}

  def reorder_product_variants(product_id, ordered_variant_ids)
      when is_list(ordered_variant_ids) do
    product_variants = list_product_variants(product_id)

    with {:ok, normalized_ids} <- normalize_variant_ids(ordered_variant_ids),
         :ok <- validate_product_variant_order(product_variants, normalized_ids) do
      product_variants_by_id = Map.new(product_variants, &{&1.id, &1})

      normalized_ids
      |> Enum.with_index()
      |> Enum.reduce(Multi.new(), fn {variant_id, display_order}, multi ->
        Multi.update(
          multi,
          {:product_variant, variant_id},
          ProductVariant.changeset(product_variants_by_id[variant_id], %{
            display_order: display_order
          })
        )
      end)
      |> Multi.run(:product_variants, fn repo, _changes ->
        {:ok,
         product_id
         |> ordered_product_variants_query()
         |> repo.all()}
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{product_variants: reordered_product_variants}} ->
          {:ok, reordered_product_variants}

        {:error, _operation, _reason, _changes} ->
          {:error, :could_not_reorder_product_variants}
      end
    end
  end

  def reorder_product_variants(_product_id, _ordered_variant_ids),
    do: {:error, :invalid_product_variant_order}

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

  def change_product_summary(%Product{} = product, attrs \\ %{}) do
    Product.summary_changeset(product, attrs)
  end

  def change_product_content(%Product{} = product, attrs \\ %{}) do
    Product.content_changeset(product, attrs)
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

  defp normalize_product_image_ids(ordered_image_ids) do
    ordered_image_ids
    |> Enum.reduce_while({:ok, []}, fn image_id, {:ok, ids} ->
      case normalize_positive_integer(image_id, nil) do
        nil -> {:halt, {:error, :invalid_product_image_order}}
        normalized_id -> {:cont, {:ok, ids ++ [normalized_id]}}
      end
    end)
  end

  defp normalize_variant_ids(ordered_variant_ids) do
    ordered_variant_ids
    |> Enum.reduce_while({:ok, []}, fn variant_id, {:ok, ids} ->
      case normalize_positive_integer(variant_id, nil) do
        nil -> {:halt, {:error, :invalid_product_variant_order}}
        normalized_id -> {:cont, {:ok, ids ++ [normalized_id]}}
      end
    end)
  end

  defp validate_product_image_order(product_images, ordered_image_ids) do
    existing_ids = Enum.map(product_images, & &1.id)

    cond do
      length(existing_ids) != length(ordered_image_ids) ->
        {:error, :invalid_product_image_order}

      length(Enum.uniq(ordered_image_ids)) != length(ordered_image_ids) ->
        {:error, :invalid_product_image_order}

      MapSet.new(existing_ids) != MapSet.new(ordered_image_ids) ->
        {:error, :invalid_product_image_order}

      true ->
        :ok
    end
  end

  defp validate_product_variant_order(product_variants, ordered_variant_ids) do
    existing_ids = Enum.map(product_variants, & &1.id)

    cond do
      length(existing_ids) != length(ordered_variant_ids) ->
        {:error, :invalid_product_variant_order}

      length(Enum.uniq(ordered_variant_ids)) != length(ordered_variant_ids) ->
        {:error, :invalid_product_variant_order}

      MapSet.new(existing_ids) != MapSet.new(ordered_variant_ids) ->
        {:error, :invalid_product_variant_order}

      true ->
        :ok
    end
  end

  defp ordered_product_images_query(product_id) do
    ProductImage
    |> where([image], image.product_id == ^product_id)
    |> order_by([image], asc: image.display_order, asc: image.id)
  end

  defp ordered_product_variants_query(product_id) do
    ProductVariant
    |> where([variant], variant.product_id == ^product_id)
    |> order_by([variant], asc: variant.display_order, asc: variant.inserted_at)
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
