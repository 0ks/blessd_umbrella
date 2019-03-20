defmodule BlessdWeb.CustomFieldChannel do
  use BlessdWeb, :channel

  alias Blessd.Custom

  def join("custom_field:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("reorder", %{"resource" => resource, "ids" => ids}, socket) do
    case Custom.reorder_fields(resource, ids, socket.assigns.current_user) do
      {:ok, _fields} ->
        {:reply, :ok, socket}

      {:error, :unauthorized} ->
        {:reply, {:error, %{message: "Unauthorized user"}}, socket}

      {:error, :unconfirmed} ->
        {:reply, {:error, %{message: "Unconfirmed user"}}, socket}
    end
  end
end
