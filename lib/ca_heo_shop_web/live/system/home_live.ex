defmodule CaHeoShopWeb.System.HomeLive do
  use CaHeoShopWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <main class="mx-auto max-w-4xl px-4 py-10 sm:px-6 lg:px-8">
        <div class="space-y-2">
          <h1 class="text-2xl font-semibold">System</h1>
          <p class="text-base-content/70">System area placeholder.</p>
        </div>
      </main>
    </Layouts.app>
    """
  end
end
