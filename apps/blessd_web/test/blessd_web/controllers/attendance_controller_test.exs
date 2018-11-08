defmodule BlessdWeb.AttendanceControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Observance

  @create_attrs %{date: ~D[2018-10-10]}

  def fixture(:service, user) do
    {:ok, service} = Observance.create_service(@create_attrs, user)
    service
  end

  describe "index" do
    test "lists all attendants", %{conn: conn} do
      user = signup()
      service = fixture(:service, user)

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.service_attendance_path(conn, :index, user.church.identifier, service))

      assert html_response(conn, 200) =~ "Attendance"
    end
  end
end
