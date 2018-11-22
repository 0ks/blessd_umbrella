defmodule BlessdWeb.AttendanceControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Observance

  @create_attrs %{"name" => "My meeting", "occurrences" => %{"0" => %{date: ~D[2018-10-10]}}}

  def fixture(:occurrence, user) do
    {:ok, %{occurrences: [occurrence]}} = Observance.create_meeting(@create_attrs, user)
    occurrence
  end

  describe "index" do
    test "lists all attendants", %{conn: conn} do
      user = signup()
      occurrence = fixture(:occurrence, user)

      conn =
        conn
        |> authenticate(user)
        |> get(
          Routes.meeting_occurrence_attendance_path(
            conn,
            :index,
            user.church.slug,
            occurrence
          )
        )

      assert html_response(conn, 200) =~ "Attendance"
    end
  end
end
