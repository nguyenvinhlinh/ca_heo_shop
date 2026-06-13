defmodule CaHeoShop.Uploads do
  @moduledoc """
  Server-side upload helpers for collection assets.
  """

  @collection_images_dir "collection_images"
  @thumb_suffix "_500x500px"
  @allowed_extensions [".png", ".jpg", ".jpeg"]

  def store_collection_image(collection_id, %{path: path, client_name: client_name}) do
    with {:ok, extension} <- normalize_extension(client_name),
         {:ok, collection_images_dir} <- collection_images_dir(),
         filename <- "#{collection_id}_#{Ecto.UUID.generate()}#{extension}",
         destination <- Path.join(collection_images_dir, filename),
         :ok <- File.cp(path, destination) do
      {:ok, filename}
    else
      {:error, _reason} = error -> error
    end
  end

  def collection_images_dir do
    case assets_root_path() do
      nil ->
        {:error, "CA_HEO_SHOP_ASSETS_PATH is missing"}

      root_path ->
        if File.dir?(root_path) do
          collection_images_dir = Path.join(root_path, @collection_images_dir)

          case File.mkdir_p(collection_images_dir) do
            :ok ->
              {:ok, collection_images_dir}

            {:error, reason} ->
              {:error, "collection_images directory is not writable: #{inspect(reason)}"}
          end
        else
          {:error, "CA_HEO_SHOP_ASSETS_PATH is invalid"}
        end
    end
  end

  def collection_image_path(filename) when is_binary(filename) do
    with {:ok, collection_images_dir} <- collection_images_dir(),
         true <- safe_filename?(filename) do
      {:ok, Path.join(collection_images_dir, filename)}
    else
      false -> {:error, :invalid_filename}
      {:error, _reason} = error -> error
    end
  end

  def thumbnail_filename(filename) when is_binary(filename) do
    ext = Path.extname(filename)
    base = Path.rootname(filename, ext)
    "#{base}#{@thumb_suffix}#{ext}"
  end

  def delete_collection_assets(nil), do: :ok

  def delete_collection_assets(image_filename) when is_binary(image_filename) do
    if static_asset_path?(image_filename) do
      :ok
    else
      with {:ok, original_path} <- collection_image_path(image_filename),
           {:ok, thumbnail_path} <- collection_image_path(thumbnail_filename(image_filename)) do
        :ok = delete_if_exists(original_path)
        :ok = delete_if_exists(thumbnail_path)
        :ok
      else
        {:error, reason} -> {:error, reason}
      end
    end
  end

  def public_collection_image_path(nil), do: nil

  def public_collection_image_path(image_filename) when is_binary(image_filename) do
    if static_asset_path?(image_filename) do
      image_filename
    else
      "/collection_images/#{image_filename}"
    end
  end

  def static_asset_path?(value) when is_binary(value), do: String.starts_with?(value, "/")

  defp assets_root_path do
    Application.get_env(:ca_heo_shop, :assets_path) || System.get_env("CA_HEO_SHOP_ASSETS_PATH")
  end

  defp normalize_extension(client_name) when is_binary(client_name) do
    extension = client_name |> Path.extname() |> String.downcase()

    cond do
      extension == ".jpeg" -> {:ok, ".jpg"}
      extension in @allowed_extensions -> {:ok, extension}
      true -> {:error, "unsupported file type"}
    end
  end

  defp safe_filename?(filename) do
    filename == Path.basename(filename) and filename != ""
  end

  defp delete_if_exists(path) do
    case File.rm(path) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
