defmodule BlessdWeb.SessionControllerTest do
  use BlessdWeb.ConnCase

  describe "new person" do
    test "renders form", %{conn: conn} do
      conn =
        conn
        |> get(Routes.session_path(conn, :new))

      assert html_response(conn, 200) =~ "Sign in"
    end
  end

  describe "create person" do
    test "redirects to index when data is valid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> post(
          Routes.session_path(conn, :create),
          session: %{
            church_slug: user.church.slug,
            email: user.email,
            password: "password"
          }
        )

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index, user.church.slug)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        conn
        |> post(
          Routes.session_path(conn, :create),
          session: %{
            church_slug: nil,
            email: nil,
            password: nil
          }
        )

      assert html_response(conn, 200) =~ "Sign in"
    end
  end

  describe "delete" do
    test "signs off", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> delete(Routes.session_path(conn, :delete, user.church.slug))

      assert redirected_to(conn) == "/"
    end
  end
end
