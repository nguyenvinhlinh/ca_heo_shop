defmodule CaHeoShop.CollectionsTest do
  use CaHeoShop.DataCase

  alias CaHeoShop.Collections
  alias CaHeoShop.Collections.Collection
  alias CaHeoShop.Uploads

  import CaHeoShop.CollectionsFixtures

  setup :set_collection_assets_path

  describe "collections" do
    test "change_collection/2 requires name_vi, name_en, and slug" do
      changeset = Collections.change_collection(%Collection{}, %{})

      assert %{name_vi: ["can't be blank"], name_en: ["can't be blank"], slug: ["can't be blank"]} =
               errors_on(changeset)
    end

    test "create_collection/1 enforces unique slug" do
      collection = collection_fixture()

      assert {:error, changeset} =
               Collections.create_collection(valid_collection_attributes(slug: collection.slug))

      assert "has already been taken" in errors_on(changeset).slug
    end

    test "change_collection/2 validates non-negative nav_display_order" do
      changeset =
        Collections.change_collection(
          %Collection{},
          valid_collection_attributes(nav_display_order: -1)
        )

      assert "must be greater than or equal to 0" in errors_on(changeset).nav_display_order
    end

    test "list_nav_collections/0 filters null nav rows and orders from zero upward" do
      hidden = collection_fixture(nav_display_order: nil, name_vi: "Hidden")
      second = collection_fixture(nav_display_order: 1, name_vi: "Second")
      first = collection_fixture(nav_display_order: 0, name_vi: "First")

      nav_collections = Collections.list_nav_collections()

      assert Enum.map(nav_collections, & &1.id) == [first.id, second.id]
      refute hidden.id in Enum.map(nav_collections, & &1.id)
    end

    test "replace_collection_image/2 stores a managed upload and marks thumbnail pending" do
      collection = collection_fixture(image_filename: nil)
      upload_path = write_temp_upload!("collection.png", "png-data")

      assert {:ok, updated_collection} =
               Collections.replace_collection_image(collection, %{
                 path: upload_path,
                 client_name: "collection.png"
               })

      assert updated_collection.has_thumbnail == false
      assert updated_collection.image_filename =~ ~r/^#{collection.id}_.+\.png$/
      assert {:ok, stored_path} = Uploads.collection_image_path(updated_collection.image_filename)
      assert File.exists?(stored_path)
    end

    test "delete_collection/1 removes uploaded collection image and thumbnail" do
      collection = collection_fixture(image_filename: nil)
      upload_path = write_temp_upload!("collection.jpg", "jpg-data")

      assert {:ok, uploaded_collection} =
               Collections.replace_collection_image(collection, %{
                 path: upload_path,
                 client_name: "collection.jpg"
               })

      assert {:ok, original_path} =
               Uploads.collection_image_path(uploaded_collection.image_filename)

      thumbnail_filename = Uploads.thumbnail_filename(uploaded_collection.image_filename)
      assert {:ok, thumbnail_path} = Uploads.collection_image_path(thumbnail_filename)
      File.write!(thumbnail_path, "thumb-data")

      assert File.exists?(original_path)
      assert File.exists?(thumbnail_path)

      assert {:ok, _deleted_collection} = Collections.delete_collection(uploaded_collection)

      refute File.exists?(original_path)
      refute File.exists?(thumbnail_path)
    end

    test "collection_display_image_path/1 prefers thumbnail when available" do
      assert Uploads.collection_display_image_path(%{
               image_filename: "42_example.jpg",
               has_thumbnail: true
             }) == "/collection_images/42_example_500x500px.jpg"
    end

    test "collection_display_image_path/1 falls back to original when thumbnail is pending or absent" do
      assert Uploads.collection_display_image_path(%{
               image_filename: "42_example.jpg",
               has_thumbnail: false
             }) == "/collection_images/42_example.jpg"

      assert Uploads.collection_display_image_path(%{
               image_filename: "42_example.jpg",
               has_thumbnail: nil
             }) == "/collection_images/42_example.jpg"
    end
  end

  defp set_collection_assets_path(_context) do
    previous = System.get_env("CA_HEO_SHOP_ASSETS_PATH")

    path =
      Path.join(
        System.tmp_dir!(),
        "ca_heo_shop_data_assets_#{System.unique_integer([:positive])}"
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

  defp write_temp_upload!(filename, contents) do
    path = Path.join(System.tmp_dir!(), "#{System.unique_integer([:positive])}-#{filename}")
    File.write!(path, contents)
    path
  end
end
