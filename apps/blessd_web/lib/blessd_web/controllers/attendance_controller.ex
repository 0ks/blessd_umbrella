defmodule BlessdWeb.AttendanceController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, %{"service_id" => service_id}) do
    church = conn.assigns.current_church
    service = Observance.get_service!(service_id, church)
    attendants = Observance.list_attendants(service, church)

    render(conn, "index.html", service: service, attendants: attendants)
  end
end
