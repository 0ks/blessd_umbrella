defmodule BlessdWeb.AttendanceController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, %{"service_id" => service_id}) do
    user = conn.assigns.current_user
    service = Observance.get_service!(service_id, user)
    people = Observance.list_people(user)

    render(conn, "index.html", service: service, people: people)
  end
end
