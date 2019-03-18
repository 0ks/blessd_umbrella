defmodule BlessdWeb.ChurchRecoveryControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.ChurchRecovery

  describe "new church recovery" do
    test "renders form", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.church_recovery_path(conn, :new))

      assert html_response(conn, 200) =~ "Forgot my Church URL"
    end
  end

  describe "create church recovery" do
    test "redirects to index when data is valid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.church_recovery_path(conn, :create), user: %{email: user.email})

      assert redirected_to(conn) == "/"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.church_recovery_path(conn, :create), user: %{email: nil})

      assert html_response(conn, 200) =~ "Forgot my Church URL"
    end
  end

  describe "edit church recovery" do
    test "renders form for editing chosen church recovery", %{conn: conn} do
      user = signup()
      {:ok, %{token: token}} = ChurchRecovery.generate_token(%{email: user.email})

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.church_recovery_path(conn, :edit, token))

      assert html_response(conn, 200) =~ "These are your churches"
    end
  end

  describe "update church recovery" do
    test "redirects when data is valid", %{conn: conn} do
      user = signup()
      {:ok, %{token: token}} = ChurchRecovery.generate_token(%{email: user.email})

      resp =
        conn
        |> authenticate(user)
        |> put(
          Routes.church_recovery_path(conn, :update, token),
          user_id: user.id,
          church_id: user.church.id
        )

      assert redirected_to(resp) == Routes.dashboard_path(conn, :index, user.church.slug)
    end
  end
end
