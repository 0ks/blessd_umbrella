defmodule BlessdWeb.AttendanceControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Observance

  @create_attrs %{name: "some name", date: ~D[2018-10-10]}

  def fixture(:service) do
    {:ok, service} = Observance.create_service(@create_attrs)
    service
  end

  describe "index" do
    setup [:create_service]

    test "lists all attendants", %{conn: conn, service: service} do
      conn = get(conn, service_attendance_path(conn, :index, service))
      assert html_response(conn, 200) =~ "Attendance"
    end
  end

  defp create_service(_) do
    service = fixture(:service)
    {:ok, service: service}
  end
end
