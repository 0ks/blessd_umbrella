defmodule BlessdWeb.AttendanceChannel do
  use BlessdWeb, :channel

  alias Blessd.Observance
  alias BlessdWeb.AttendanceView
  alias Phoenix.View

  def join("attendance:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("search", %{"meeting_id" => meeting_id, "query" => query}, socket) do
    user = socket.assigns.current_user

    meeting = Observance.get_meeting!(meeting_id, user)
    people = Observance.search_people(query, user)

    html =
      View.render_to_string(AttendanceView, "table_body.html", people: people, meeting: meeting)

    {:reply, {:ok, %{table_body: html}}, socket}
  end

  def handle_in("toggle", %{"person_id" => person_id, "meeting_id" => meeting_id}, socket) do
    user = socket.assigns.current_user

    person_id
    |> Observance.toggle_attendant(meeting_id, user)
    |> case do
      {:ok, _attendant} ->
        {:reply, :ok, socket}

      {:error, %Ecto.Changeset{}} ->
        {:reply, {:error, "Failed to toggle attendant"}, socket}
    end
  end
end
