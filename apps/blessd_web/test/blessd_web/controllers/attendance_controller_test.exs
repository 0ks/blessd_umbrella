defmodule BlessdWeb.AttendanceControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Observance

  @create_attrs %{date: ~D[2018-10-10]}

  def fixture(:service, church) do
    {:ok, service} = Observance.create_service(@create_attrs, church)
    service
  end

  describe "index" do
    test "lists all attendants", %{conn: conn} do
      church = auth_church()
      service = fixture(:service, church)
      conn = get(conn, service_attendance_path(conn, :index, church, service))
      assert html_response(conn, 200) =~ "Attendance"
    end
  end
end
