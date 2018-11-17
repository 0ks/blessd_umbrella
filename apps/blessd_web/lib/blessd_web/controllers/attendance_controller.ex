defmodule BlessdWeb.AttendanceController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, %{"meeting_id" => meeting_id}) do
    user = conn.assigns.current_user
    meeting = Observance.get_meeting!(meeting_id, user)
    people = Observance.list_people(user)

    render(conn, "index.html", meeting: meeting, people: people)
  end
end
