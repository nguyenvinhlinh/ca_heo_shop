defmodule CaHeoShopWeb.CollectionLive do
  use CaHeoShopWeb, :live_view

  alias CaHeoShop.Collections
  alias CaHeoShop.Collections.Collection
  alias CaHeoShop.Uploads
  alias CaHeoShopWeb.AdminLive

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:collections, [])
      |> assign(:selected_collection, %Collection{})
      |> assign(:collection_delete_open, false)
      |> assign(:collection_form, to_form(Collections.change_collection(%Collection{})))
      |> allow_upload(:collection_image,
        accept: ~w(.png .jpg .jpeg),
        max_entries: 1,
        max_file_size: 1_000_000
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate_collection", %{"collection" => params}, socket) do
    changeset =
      socket.assigns.selected_collection
      |> Collections.change_collection(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :collection_form, to_form(changeset))}
  end

  def handle_event("save_collection", %{"collection" => params}, socket) do
    save_collection(socket, socket.assigns.live_action, params)
  end

  def handle_event("validate_collection_image_upload", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("upload_collection_image", _params, socket) do
    errors = upload_errors(socket.assigns.uploads.collection_image)

    cond do
      errors != [] ->
        {:noreply, put_flash(socket, :error, upload_error_message(List.first(errors)))}

      uploaded_entries(socket, :collection_image) == {[], []} ->
        {:noreply, put_flash(socket, :error, "Please select an image file to upload")}

      true ->
        result =
          consume_uploaded_entries(socket, :collection_image, fn meta, entry ->
            case validate_upload_entry(entry) do
              :ok ->
                case Collections.replace_collection_image(socket.assigns.selected_collection, %{
                       path: meta.path,
                       client_name: entry.client_name
                     }) do
                  {:ok, collection} -> {:ok, {:ok, collection}}
                  {:error, %Ecto.Changeset{} = changeset} -> {:ok, {:error, changeset}}
                  {:error, message} -> {:ok, {:error, message}}
                end

              {:error, message} ->
                {:postpone, message}
            end
          end)
          |> List.first()

        case result do
          {:ok, collection} ->
            {:noreply,
             socket
             |> assign(:selected_collection, collection)
             |> assign(:collection_form, to_form(Collections.change_collection(collection)))
             |> put_flash(:info, "Collection image uploaded")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply,
             socket
             |> assign(:collection_form, to_form(changeset))
             |> put_flash(:error, "Unable to update the collection image")}

          {:error, message} when is_binary(message) ->
            {:noreply, put_flash(socket, :error, message)}

          _ ->
            {:noreply, put_flash(socket, :error, "Unable to read the uploaded image")}
        end
    end
  end

  def handle_event("open_collection_delete", %{"slug" => slug}, socket) do
    {:noreply,
     socket
     |> assign(:selected_collection, Collections.get_collection_by_slug!(slug))
     |> assign(:collection_delete_open, true)}
  end

  def handle_event("close_collection_delete", _params, socket) do
    {:noreply, assign(socket, :collection_delete_open, false)}
  end

  def handle_event("delete_collection", _params, socket) do
    case Collections.delete_collection(socket.assigns.selected_collection) do
      {:ok, _collection} ->
        {:noreply,
         socket
         |> put_flash(:info, "Collection deleted")
         |> assign(:collection_delete_open, false)
         |> push_navigate(to: ~p"/admin/collections")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, put_flash(socket, :error, delete_collection_error_message(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} variant={:admin}>
      <AdminLive.admin_shell current_scope={@current_scope} active={@live_action}>
        <%= case @live_action do %>
          <% :collections -> %>
            <.collections_page
              collections={@collections}
              selected_collection={@selected_collection}
              collection_delete_open={@collection_delete_open}
            />
          <% :collection_new -> %>
            <.collection_form_page
              collection={@selected_collection}
              form={@collection_form}
              mode={:new}
              uploads={@uploads}
            />
          <% :collection_edit -> %>
            <.collection_form_page
              collection={@selected_collection}
              form={@collection_form}
              mode={:edit}
              uploads={@uploads}
            />
        <% end %>
      </AdminLive.admin_shell>
    </Layouts.app>
    """
  end

  attr :collections, :list, required: true
  attr :selected_collection, :any, required: true
  attr :collection_delete_open, :boolean, required: true

  def collections_page(assigns) do
    ~H"""
    <AdminLive.page_header
      title="Collections"
      section="Ecommerce"
      description="Manage storefront collection groups and header navigation visibility."
    >
      <:actions>
        <.link navigate={~p"/admin/collections/new"} class="btn btn-primary btn-sm">
          <.icon name="hero-plus" class="size-4" /> Create collection
        </.link>
      </:actions>
    </AdminLive.page_header>

    <section class="card mt-6 bg-base-100 shadow-sm">
      <%= if @collections == [] do %>
        <div class="card-body">
          <div class="rounded-box border border-dashed border-base-300 bg-base-200/60 p-8 text-center">
            <h2 class="text-base font-medium">No collections yet</h2>
            <p class="mt-2 text-sm text-base-content/60">
              Create the first collection to control storefront grouping and header navigation.
            </p>
            <div class="mt-4">
              <.link navigate={~p"/admin/collections/new"} class="btn btn-primary btn-sm">
                <.icon name="hero-plus" class="size-4" /> Create collection
              </.link>
            </div>
          </div>
        </div>
      <% else %>
        <div class="overflow-auto">
          <table class="table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Slug</th>
                <th>Navigation</th>
                <th>Description</th>
                <th>Updated At</th>
                <th class="text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={collection <- @collections} class="hover:bg-base-200/40">
                <td>
                  <div class="flex items-center gap-3">
                    <%= if collection.image_filename do %>
                      <img
                        src={Uploads.collection_display_image_path(collection)}
                        alt=""
                        class="size-10 rounded-box object-cover"
                      />
                    <% else %>
                      <div class="flex size-10 items-center justify-center rounded-box bg-base-200 text-base-content/50">
                        <.icon name="hero-photo" class="size-5" />
                      </div>
                    <% end %>
                    <div>
                      <p class="font-medium">{collection.name_vi}</p>
                      <p class="text-xs text-base-content/60">{collection.name_en}</p>
                    </div>
                  </div>
                </td>
                <td>/{collection.slug}</td>
                <td>
                  <span class={[
                    "badge badge-sm",
                    if(collection.nav_display_order == nil,
                      do: "badge-outline",
                      else: "badge-primary badge-soft"
                    )
                  ]}>
                    {collection_nav_label(collection)}
                  </span>
                </td>
                <td class="max-w-sm">
                  <p class="line-clamp-2 text-sm text-base-content/70">
                    {collection_summary(collection)}
                  </p>
                </td>
                <td>{format_datetime(collection.updated_at)}</td>
                <td class="text-right">
                  <AdminLive.row_actions
                    view={~p"/collections/#{collection.slug}"}
                    edit={~p"/admin/collections/#{collection.slug}/edit"}
                    delete_click="open_collection_delete"
                    delete_value={collection.slug}
                  />
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div
          :if={@collection_delete_open}
          class="fixed inset-0 z-50 flex items-center justify-center bg-base-content/30 p-4 backdrop-blur-sm"
        >
          <div class="w-full max-w-2xl rounded-box border border-base-300 bg-base-100 shadow-xl">
            <div class="p-6">
              <div class="flex items-start gap-4">
                <div class="rounded-box bg-error/10 p-3 text-error">
                  <.icon name="hero-exclamation-triangle" class="size-6" />
                </div>
                <div class="min-w-0 flex-1">
                  <h2 class="text-lg font-semibold">Delete collection?</h2>
                  <p class="mt-2 text-sm text-base-content/70">
                    This action deletes the collection record. It is blocked if products still belong to this collection.
                  </p>
                  <div class="mt-5 rounded-box bg-base-200 p-4">
                    <p class="font-medium">{@selected_collection.name_vi}</p>
                    <p
                      :if={@selected_collection.name_en && @selected_collection.name_en != ""}
                      class="text-sm text-base-content/60"
                    >
                      {@selected_collection.name_en}
                    </p>
                    <p class="text-sm text-base-content/60">/{@selected_collection.slug}</p>
                  </div>
                </div>
              </div>
              <div class="mt-6 flex justify-end gap-3">
                <button class="btn btn-ghost" type="button" phx-click="close_collection_delete">
                  Cancel
                </button>
                <button class="btn btn-error" type="button" phx-click="delete_collection">
                  Delete collection
                </button>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </section>
    """
  end

  attr :collection, :any, required: true
  attr :form, :any, required: true
  attr :mode, :atom, required: true
  attr :uploads, :map, required: true

  def collection_form_page(assigns) do
    assigns =
      assigns
      |> assign(
        :title,
        if(assigns.mode == :new, do: "Create Collection", else: "Edit Collection")
      )
      |> assign(
        :primary_action,
        if(assigns.mode == :new, do: "Create Collection", else: "Save Changes")
      )

    ~H"""
    <AdminLive.page_header
      title={@title}
      section="Ecommerce"
      description="Manage bilingual collection labels and storefront navigation placement."
    />

    <section class="mt-6 grid gap-6 xl:grid-cols-[1fr_22rem]">
      <div class="card bg-base-100 shadow-sm">
        <div class="card-body">
          <h2 class="card-title text-base">Collection Information</h2>
          <.form
            for={@form}
            id="collection-form"
            phx-change="validate_collection"
            phx-submit="save_collection"
            class="mt-4"
          >
            <div class="grid gap-4 lg:grid-cols-2">
              <.input field={@form[:name_vi]} label="Vietnamese name" />
              <.input field={@form[:name_en]} label="English name" />
              <.input field={@form[:slug]} label="Slug" />
              <.input
                field={@form[:description_vi]}
                type="textarea"
                label="Vietnamese description"
                class="textarea w-full lg:col-span-2"
              />
              <.input
                field={@form[:description_en]}
                type="textarea"
                label="English description"
                class="textarea w-full lg:col-span-2"
              />
              <div>
                <.input
                  field={@form[:nav_display_order]}
                  type="number"
                  label="Header navigation order"
                />
                <p class="mt-1 text-xs text-base-content/60">
                  Leave blank to hide this collection from the header navigation.
                </p>
              </div>
            </div>
            <div class="mt-6 flex justify-end gap-3">
              <.link navigate={~p"/admin/collections"} class="btn btn-ghost">Cancel</.link>
              <button class="btn btn-primary" type="submit">{@primary_action}</button>
            </div>
          </.form>
        </div>
      </div>

      <aside class="grid gap-6">
        <div class="card bg-base-100 shadow-sm">
          <div class="card-body">
            <h2 class="card-title text-base">Image Preview</h2>
            <div class="flex aspect-square items-center justify-center rounded-box border border-dashed border-base-300 bg-base-200">
              <%= if @collection.image_filename do %>
                <img
                  src={Uploads.collection_display_image_path(@collection)}
                  alt=""
                  class="size-full rounded-box object-cover"
                />
              <% else %>
                <.icon name="hero-photo" class="size-10 text-base-content/40" />
              <% end %>
            </div>
            <p class="text-sm text-base-content/60">
              Uploads replace the current collection image. Thumbnail generation runs after the upload is saved.
            </p>
          </div>
        </div>

        <%= if @mode == :edit and @collection.id do %>
          <div class="card bg-base-100 shadow-sm">
            <div class="card-body">
              <h2 class="card-title text-base">Upload Collection Image</h2>
              <form
                id="collection-image-form"
                phx-change="validate_collection_image_upload"
                phx-submit="upload_collection_image"
                class="mt-2"
              >
                <div class="space-y-3">
                  <.live_file_input
                    upload={@uploads.collection_image}
                    class="file-input file-input-bordered w-full"
                  />
                  <div
                    :for={err <- upload_errors(@uploads.collection_image)}
                    class="text-sm text-error"
                  >
                    {upload_error_message(err)}
                  </div>
                  <div
                    :for={entry <- @uploads.collection_image.entries}
                    class="rounded-box bg-base-200 p-3 text-sm"
                  >
                    <p class="font-medium">{entry.client_name}</p>
                    <p class="text-base-content/60">{entry.progress}%</p>
                    <div
                      :for={err <- upload_errors(@uploads.collection_image, entry)}
                      class="mt-1 text-error"
                    >
                      {upload_error_message(err)}
                    </div>
                  </div>
                  <p class="text-xs text-base-content/60">
                    PNG, JPG, or JPEG only. Maximum file size: 1MB.
                  </p>
                  <div class="flex justify-end">
                    <button class="btn btn-primary btn-sm" type="submit">Upload image</button>
                  </div>
                </div>
              </form>
            </div>
          </div>
        <% end %>
      </aside>
    </section>
    """
  end

  defp page_title(:collections), do: "Admin Collections"
  defp page_title(:collection_new), do: "Create Collection"
  defp page_title(:collection_edit), do: "Edit Collection"

  defp apply_action(socket, :collections, _params) do
    socket
    |> assign(:collections, Collections.list_collections())
    |> assign(:collection_delete_open, false)
  end

  defp apply_action(socket, :collection_new, _params) do
    collection = %Collection{}

    socket
    |> assign(:selected_collection, collection)
    |> assign(:collection_form, to_form(Collections.change_collection(collection)))
  end

  defp apply_action(socket, :collection_edit, %{"slug" => slug}) do
    collection = Collections.get_collection_by_slug!(slug)

    socket
    |> assign(:selected_collection, collection)
    |> assign(:collection_form, to_form(Collections.change_collection(collection)))
  end

  defp save_collection(socket, :collection_new, params) do
    case Collections.create_collection(params) do
      {:ok, _collection} ->
        {:noreply,
         socket
         |> put_flash(:info, "Collection created")
         |> push_navigate(to: ~p"/admin/collections")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :collection_form, to_form(changeset))}
    end
  end

  defp save_collection(socket, :collection_edit, params) do
    case Collections.update_collection(socket.assigns.selected_collection, params) do
      {:ok, collection} ->
        {:noreply,
         socket
         |> assign(:selected_collection, collection)
         |> put_flash(:info, "Collection updated")
         |> push_navigate(to: ~p"/admin/collections")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :collection_form, to_form(changeset))}
    end
  end

  defp collection_nav_label(%{nav_display_order: nil}), do: "Hidden"
  defp collection_nav_label(%{nav_display_order: order}), do: "Header ##{order}"

  defp collection_summary(collection) do
    summary =
      collection.description_vi ||
        collection.description_en ||
        "No description yet"

    String.slice(summary, 0, 120)
  end

  defp format_datetime(%DateTime{} = value) do
    Calendar.strftime(value, "%Y-%m-%d %H:%M")
  end

  defp delete_collection_error_message(%Ecto.Changeset{errors: errors}) do
    if Keyword.has_key?(errors, :collection_id) do
      "Cannot delete this collection while products still belong to it."
    else
      "Unable to delete this collection"
    end
  end

  defp validate_upload_entry(entry) do
    cond do
      not String.starts_with?(entry.client_type || "", "image/") ->
        {:error, "Only image files are allowed"}

      true ->
        :ok
    end
  end

  defp upload_error_message(:too_large), do: "File must be 1MB or smaller"
  defp upload_error_message(:not_accepted), do: "Only PNG, JPG, and JPEG files are allowed"
  defp upload_error_message(message) when is_binary(message), do: message
  defp upload_error_message(_error), do: "Invalid upload"
end
