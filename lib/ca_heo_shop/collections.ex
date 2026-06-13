defmodule CaHeoShop.Collections do
  @moduledoc """
  The Collections context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias CaHeoShop.Repo

  alias CaHeoShop.Collections.Collection
  alias CaHeoShop.Uploads

  def list_collections do
    Collection
    |> order_by([c], asc_nulls_last: c.nav_display_order, asc: c.id)
    |> Repo.all()
  end

  def list_nav_collections do
    Collection
    |> where([c], not is_nil(c.nav_display_order))
    |> order_by([c], asc: c.nav_display_order, asc: c.name_vi)
    |> Repo.all()
  end

  def list_filterable_collections do
    Collection
    |> order_by([c], asc_nulls_last: c.nav_display_order, asc: c.name_vi, asc: c.name_en)
    |> Repo.all()
  end

  def get_collection!(id), do: Repo.get!(Collection, id)

  def get_collection_by_slug!(slug) when is_binary(slug) do
    Repo.get_by!(Collection, slug: slug)
  end

  def create_collection(attrs \\ %{}) do
    %Collection{}
    |> Collection.changeset(attrs)
    |> Repo.insert()
  end

  def update_collection(%Collection{} = collection, attrs) do
    collection
    |> Collection.changeset(attrs)
    |> Repo.update()
  end

  def delete_collection(%Collection{} = collection) do
    case Repo.delete(collection) do
      {:ok, deleted_collection} ->
        maybe_delete_collection_assets(deleted_collection.image_filename)
        {:ok, deleted_collection}
    end
  rescue
    error in Ecto.ConstraintError ->
      case error.constraint do
        "products_collection_id_fkey" ->
          changeset =
            collection
            |> Ecto.Changeset.change()
            |> Ecto.Changeset.add_error(
              :collection_id,
              "cannot delete this collection while products still belong to it"
            )

          {:error, changeset}

        _other ->
          reraise error, __STACKTRACE__
      end
  end

  def change_collection(%Collection{} = collection, attrs \\ %{}) do
    Collection.changeset(collection, attrs)
  end

  def update_collection_image(%Collection{} = collection, image_filename)
      when is_binary(image_filename) do
    collection
    |> Ecto.Changeset.change(image_filename: image_filename, has_thumbnail: false)
    |> Repo.update()
  end

  def clear_collection_image(%Collection{} = collection) do
    collection
    |> Ecto.Changeset.change(image_filename: nil, has_thumbnail: nil)
    |> Repo.update()
  end

  def delete_collection_image(%Collection{} = collection) do
    image_filename = collection.image_filename

    case clear_collection_image(collection) do
      {:ok, updated_collection} ->
        maybe_delete_collection_assets(image_filename)
        {:ok, updated_collection}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def mark_collection_thumbnail_generated(%Collection{} = collection) do
    collection
    |> Ecto.Changeset.change(has_thumbnail: true)
    |> Repo.update()
  end

  def list_collections_pending_thumbnail do
    Collection
    |> where([c], c.has_thumbnail == false and not is_nil(c.image_filename))
    |> Repo.all()
  end

  def replace_collection_image(%Collection{} = collection, upload_meta) do
    old_image_filename = collection.image_filename

    case Uploads.store_collection_image(collection.id, upload_meta) do
      {:ok, new_image_filename} ->
        case update_collection_image(collection, new_image_filename) do
          {:ok, updated_collection} ->
            maybe_delete_collection_assets(old_image_filename)
            {:ok, updated_collection}

          {:error, %Ecto.Changeset{} = changeset} ->
            maybe_delete_collection_assets(new_image_filename)
            {:error, changeset}
        end

      {:error, message} when is_binary(message) ->
        {:error, message}
    end
  end

  defp maybe_delete_collection_assets(nil), do: :ok

  defp maybe_delete_collection_assets(image_filename) do
    case Uploads.delete_collection_assets(image_filename) do
      :ok ->
        :ok

      {:error, reason} ->
        Logger.warning(
          "failed to delete collection assets for #{image_filename}: #{inspect(reason)}"
        )

        :ok
    end
  end
end
