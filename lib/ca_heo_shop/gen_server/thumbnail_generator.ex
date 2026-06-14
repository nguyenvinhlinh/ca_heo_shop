defmodule CaHeoShop.GenServer.ThumbnailGenerator do
  use GenServer

  alias CaHeoShop.Collections
  alias CaHeoShop.Products
  alias CaHeoShop.Products.ProductImage
  alias CaHeoShop.Uploads
  require Logger

  @interval_ms 5_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def process_pending_collections do
    Collections.list_collections_pending_thumbnail()
    |> Enum.each(&process_collection/1)
  end

  def process_pending_product_images do
    Products.list_product_images_without_thumbnail()
    |> Enum.each(&process_product_image/1)
  end

  def process_pending_thumbnails do
    process_pending_collections()
    process_pending_product_images()
  end

  @impl true
  def init(_opts) do
    send(self(), :process_pending_thumbnails)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:process_pending_thumbnails, state) do
    process_pending_thumbnails()
    Process.send_after(self(), :process_pending_thumbnails, @interval_ms)
    {:noreply, state}
  end

  defp process_collection(collection) do
    with image_filename when is_binary(image_filename) <- collection.image_filename,
         {:ok, input_path} <- Uploads.collection_image_path(image_filename),
         {:ok, output_path} <-
           Uploads.collection_image_path(Uploads.thumbnail_filename(image_filename)),
         :ok <- ffmpeg_runner().generate_square_thumbnail(input_path, output_path, 500),
         {:ok, _collection} <- Collections.mark_collection_thumbnail_generated(collection) do
      :ok
    else
      _error ->
        Uploads.delete_collection_assets(collection.image_filename)
        Collections.clear_collection_image(collection)
        :error
    end
  end

  defp process_product_image(%ProductImage{} = product_image) do
    thumbnail_filename = Uploads.thumbnail_filename(product_image.filename)

    cond do
      product_image.has_thumbnail == true ->
        :ok

      product_thumbnail_exists?(thumbnail_filename) ->
        case Products.mark_product_image_thumbnail_generated(product_image) do
          {:ok, _updated_product_image} -> :ok
          {:error, _changeset} -> :error
        end

      true ->
        with {:ok, input_path} <- Uploads.product_image_path(product_image.filename),
             true <- File.exists?(input_path) || {:error, :missing_original_file},
             {:ok, output_path} <- Uploads.product_image_path(thumbnail_filename),
             :ok <- ffmpeg_runner().generate_square_thumbnail(input_path, output_path, 500),
             true <- File.exists?(output_path) || {:error, :missing_thumbnail_file},
             {:ok, _product_image} <-
               Products.mark_product_image_thumbnail_generated(product_image) do
          :ok
        else
          {:error, :missing_original_file} ->
            Logger.warning(
              "product image original file missing for product_image_id=#{product_image.id} filename=#{product_image.filename}"
            )

            delete_invalid_product_image(product_image)

          {:error, reason} ->
            Logger.error(
              "product image thumbnail generation failed for product_image_id=#{product_image.id} filename=#{product_image.filename}: #{inspect(reason)}"
            )

            delete_invalid_product_image(product_image)

          false ->
            Logger.error(
              "product image thumbnail generation failed for product_image_id=#{product_image.id} filename=#{product_image.filename}: unexpected false result"
            )

            delete_invalid_product_image(product_image)

          _other ->
            Logger.error(
              "product image thumbnail generation failed for product_image_id=#{product_image.id} filename=#{product_image.filename}: unexpected error"
            )

            delete_invalid_product_image(product_image)
        end
    end
  end

  defp product_thumbnail_exists?(thumbnail_filename) do
    case Uploads.product_image_path(thumbnail_filename) do
      {:ok, thumbnail_path} -> File.exists?(thumbnail_path)
      {:error, _reason} -> false
    end
  end

  defp delete_invalid_product_image(product_image) do
    case Products.delete_product_image(product_image) do
      {:ok, _deleted_product_image} ->
        :error

      {:error, _reason} ->
        :error
    end
  end

  defp ffmpeg_runner do
    Application.get_env(:ca_heo_shop, :ffmpeg_runner, CaHeoShop.FFmpegRunner)
  end
end
