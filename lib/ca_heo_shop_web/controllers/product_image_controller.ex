defmodule CaHeoShopWeb.ProductImageController do
  use CaHeoShopWeb, :controller

  alias CaHeoShop.Uploads

  def show(conn, %{"filename" => filename}) do
    case Uploads.product_image_path(filename) do
      {:ok, path} ->
        if File.exists?(path) do
          send_file(conn, 200, path)
        else
          send_resp(conn, 404, "Not found")
        end

      {:error, _reason} ->
        send_resp(conn, 404, "Not found")
    end
  end
end
