defmodule BlessdWeb.AttendanceController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, %{"service_id" => service_id}) do
    service = Observance.get_service!(service_id)
    attendants = Observance.list_attendants(service)

    render(conn, "index.html", service: service, attendants: attendants)
  end
end
