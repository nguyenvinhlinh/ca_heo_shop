defmodule CaHeoShop.GenServer.ThumbnailGenerator do
  use GenServer

  alias CaHeoShop.Collections
  alias CaHeoShop.Uploads

  @interval_ms 5_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def process_pending_collections do
    Collections.list_collections_pending_thumbnail()
    |> Enum.each(&process_collection/1)
  end

  @impl true
  def init(_opts) do
    send(self(), :process_pending_collections)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:process_pending_collections, state) do
    process_pending_collections()
    Process.send_after(self(), :process_pending_collections, @interval_ms)
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

  defp ffmpeg_runner do
    Application.get_env(:ca_heo_shop, :ffmpeg_runner, CaHeoShop.FFmpegRunner)
  end
end
