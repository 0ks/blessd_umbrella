defmodule BlessdWeb.DashboardControllerTest do
  use BlessdWeb.ConnCase

  test "index shows welcome text when no card is there", %{conn: conn} do
    user = signup()

    conn =
      conn
      |> authenticate(user)
      |> get(Routes.dashboard_path(conn, :index, user.church.slug))

    assert html_response(conn, 200) =~ "Keep in touch!"
  end
end
