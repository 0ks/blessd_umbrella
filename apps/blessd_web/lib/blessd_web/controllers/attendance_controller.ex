defmodule BlessdWeb.AttendanceController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, %{"meeting_occurrence_id" => occurrence_id}) do
    user = conn.assigns.current_user
    occurrence = Observance.get_occurrence!(occurrence_id, user)
    people = Observance.list_people(user)

    render(conn, "index.html", occurrence: occurrence, people: people)
  end
end
