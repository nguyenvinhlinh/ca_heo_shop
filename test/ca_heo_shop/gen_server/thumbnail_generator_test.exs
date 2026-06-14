defmodule CaHeoShop.GenServer.ThumbnailGeneratorTest do
  use CaHeoShop.DataCase

  alias CaHeoShop.Collections
  alias CaHeoShop.GenServer.ThumbnailGenerator
  alias CaHeoShop.Products
  alias CaHeoShop.Uploads

  import CaHeoShop.CollectionsFixtures
  import CaHeoShop.ProductsFixtures

  setup :set_collection_assets_path
  setup :set_ffmpeg_runner

  describe "process_pending_collections/0" do
    test "generates a 500x500 thumbnail and marks the collection ready" do
      collection = collection_fixture(image_filename: nil)
      upload_path = write_temp_upload!("collection.png", "png-data")

      assert {:ok, uploaded_collection} =
               Collections.replace_collection_image(collection, %{
                 path: upload_path,
                 client_name: "collection.png"
               })

      Application.put_env(:ca_heo_shop, :ffmpeg_runner, __MODULE__.FFmpegRunnerSuccess)

      ThumbnailGenerator.process_pending_collections()

      updated_collection = Collections.get_collection!(uploaded_collection.id)

      assert updated_collection.has_thumbnail == true
      assert updated_collection.image_filename == uploaded_collection.image_filename

      assert {:ok, thumbnail_path} =
               Uploads.collection_image_path(
                 Uploads.thumbnail_filename(uploaded_collection.image_filename)
               )

      assert File.exists?(thumbnail_path)
    end

    test "clears the uploaded image when ffmpeg thumbnail generation fails" do
      collection = collection_fixture(image_filename: nil)
      upload_path = write_temp_upload!("collection.png", "png-data")

      assert {:ok, uploaded_collection} =
               Collections.replace_collection_image(collection, %{
                 path: upload_path,
                 client_name: "collection.png"
               })

      assert {:ok, original_path} =
               Uploads.collection_image_path(uploaded_collection.image_filename)

      Application.put_env(:ca_heo_shop, :ffmpeg_runner, __MODULE__.FFmpegRunnerFailure)

      ThumbnailGenerator.process_pending_collections()

      updated_collection = Collections.get_collection!(uploaded_collection.id)

      assert updated_collection.image_filename == nil
      assert updated_collection.has_thumbnail == nil
      refute File.exists?(original_path)
    end
  end

  describe "process_pending_product_images/0" do
    test "generates a 500x500 thumbnail and marks the product image ready" do
      product = product_fixture()
      upload_path = write_temp_upload!("product-image.png", "png-data")

      assert {:ok, product_image} =
               Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "product-image.png"
               })

      Application.put_env(:ca_heo_shop, :ffmpeg_runner, __MODULE__.FFmpegRunnerSuccess)

      ThumbnailGenerator.process_pending_product_images()

      updated_product_image = Products.get_product_image!(product_image.id)

      assert updated_product_image.has_thumbnail == true
      assert updated_product_image.filename == product_image.filename

      assert {:ok, thumbnail_path} =
               Uploads.product_image_path(Uploads.thumbnail_filename(product_image.filename))

      assert File.exists?(thumbnail_path)
    end

    test "marks product image ready when the thumbnail file already exists" do
      product = product_fixture()
      upload_path = write_temp_upload!("product-image.jpg", "jpg-data")

      assert {:ok, product_image} =
               Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "product-image.jpg"
               })

      assert {:ok, thumbnail_path} =
               Uploads.product_image_path(Uploads.thumbnail_filename(product_image.filename))

      File.write!(thumbnail_path, "thumb-data")

      Application.put_env(:ca_heo_shop, :ffmpeg_runner, __MODULE__.FFmpegRunnerFailure)

      ThumbnailGenerator.process_pending_product_images()

      updated_product_image = Products.get_product_image!(product_image.id)
      assert updated_product_image.has_thumbnail == true
      assert File.exists?(thumbnail_path)
    end

    test "deletes the product image when the original file is missing" do
      product = product_fixture()
      upload_path = write_temp_upload!("missing-product-image.jpg", "jpg-data")

      assert {:ok, product_image} =
               Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "missing-product-image.jpg"
               })

      assert {:ok, original_path} = Uploads.product_image_path(product_image.filename)
      File.rm!(original_path)

      ThumbnailGenerator.process_pending_product_images()

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product_image!(product_image.id)
      end
    end

    test "deletes the invalid product image when ffmpeg thumbnail generation fails" do
      product = product_fixture()
      upload_path = write_temp_upload!("invalid-product-image.jpg", "jpg-data")

      assert {:ok, product_image} =
               Products.add_product_image_upload(product, %{
                 path: upload_path,
                 client_name: "invalid-product-image.jpg"
               })

      assert {:ok, original_path} = Uploads.product_image_path(product_image.filename)

      Application.put_env(:ca_heo_shop, :ffmpeg_runner, __MODULE__.FFmpegRunnerFailure)

      ThumbnailGenerator.process_pending_product_images()

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product_image!(product_image.id)
      end

      refute File.exists?(original_path)
    end
  end

  defmodule FFmpegRunnerSuccess do
    def generate_square_thumbnail(_input_path, output_path, 500) do
      File.write!(output_path, "thumb-data")
      :ok
    end
  end

  defmodule FFmpegRunnerFailure do
    def generate_square_thumbnail(_input_path, _output_path, 500) do
      {:error, "ffmpeg failed"}
    end
  end

  defp set_collection_assets_path(_context) do
    previous = System.get_env("CA_HEO_SHOP_ASSETS_PATH")

    path =
      Path.join(
        System.tmp_dir!(),
        "ca_heo_shop_thumb_assets_#{System.unique_integer([:positive])}"
      )

    File.mkdir_p!(path)
    System.put_env("CA_HEO_SHOP_ASSETS_PATH", path)

    on_exit(fn ->
      if previous do
        System.put_env("CA_HEO_SHOP_ASSETS_PATH", previous)
      else
        System.delete_env("CA_HEO_SHOP_ASSETS_PATH")
      end

      File.rm_rf(path)
    end)

    :ok
  end

  defp set_ffmpeg_runner(_context) do
    previous = Application.get_env(:ca_heo_shop, :ffmpeg_runner)

    on_exit(fn ->
      if previous do
        Application.put_env(:ca_heo_shop, :ffmpeg_runner, previous)
      else
        Application.delete_env(:ca_heo_shop, :ffmpeg_runner)
      end
    end)

    :ok
  end

  defp write_temp_upload!(filename, contents) do
    path = Path.join(System.tmp_dir!(), "#{System.unique_integer([:positive])}-#{filename}")
    File.write!(path, contents)
    path
  end
end
