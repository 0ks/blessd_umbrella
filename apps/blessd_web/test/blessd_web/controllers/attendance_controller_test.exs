defmodule BlessdWeb.AttendanceControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Observance

  @create_attrs %{date: ~D[2018-10-10]}

  def fixture(:meeting, user) do
    {:ok, meeting} = Observance.create_meeting(@create_attrs, user)
    meeting
  end

  describe "index" do
    test "lists all attendants", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.meeting_attendance_path(conn, :index, user.church.identifier, meeting))

      assert html_response(conn, 200) =~ "Attendance"
    end
  end
end
