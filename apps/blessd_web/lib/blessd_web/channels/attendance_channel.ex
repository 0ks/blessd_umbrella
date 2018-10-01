defmodule BlessdWeb.AttendanceChannel do
  use BlessdWeb, :channel

  alias Blessd.Observance
  alias BlessdWeb.AttendanceView
  alias Phoenix.View

  def join("attendance:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("search", %{"service_id" => service_id, "query" => query}, socket) do
    attendants = Observance.search_attendants(service_id, query)
    html = View.render_to_string(AttendanceView, "table_body.html", attendants: attendants)

    {:reply, {:ok, %{table_body: html}}, socket}
  end

  def handle_in("update", %{"id" => id, "attendant" => attendant_params}, socket) do
    id
    |> Observance.get_attendant!()
    |> Observance.update_attendant(attendant_params)
    |> case do
      {:ok, _attendant} ->
        {:reply, :ok, socket}

      {:error, %Ecto.Changeset{}} ->
        {:reply, {:error, "Failed to update attendant"}, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
