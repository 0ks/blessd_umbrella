defmodule BlessdWeb.AttendanceChannel do
  use BlessdWeb, :channel

  alias Blessd.Observance
  alias BlessdWeb.AttendanceView
  alias Phoenix.View

  def join("attendance:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("search", %{"service_id" => service_id, "query" => query}, socket) do
    church = socket.assigns.current_church

    attendants =
      service_id
      |> Observance.get_service!(church)
      |> Observance.search_attendants(query, church)

    html = View.render_to_string(AttendanceView, "table_body.html", attendants: attendants)

    {:reply, {:ok, %{table_body: html}}, socket}
  end

  def handle_in("update", %{"id" => id, "attendant" => attendant_params}, socket) do
    church = socket.assigns.current_church

    id
    |> Observance.get_attendant!(church)
    |> Observance.update_attendant(attendant_params, church)
    |> case do
      {:ok, _attendant} ->
        {:reply, :ok, socket}

      {:error, %Ecto.Changeset{}} ->
        {:reply, {:error, "Failed to update attendant"}, socket}
    end
  end
end
