defmodule BlessdWeb.AttendanceController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, %{"meeting_occurrence_id" => occurrence_id}) do
    with user = conn.assigns.current_user,
         {:ok, occurrence} <- Observance.find_occurrence(occurrence_id, user),
         {:ok, people} <- Observance.list_people(user) do
      render(conn, "index.html", occurrence: occurrence, people: people)
    end
  end
end
