defmodule CaHeoShop.Collections do
  @moduledoc """
  The Collections context.
  """

  import Ecto.Query, warn: false
  alias CaHeoShop.Repo

  alias CaHeoShop.Collections.Collection

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
    Repo.delete(collection)
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
end
