defmodule BlessdWeb.SignupControllerTest do
  use BlessdWeb.ConnCase

  @create_attrs %{
    "church" => %{name: "Signup Church", slug: "signup_church"},
    "user" => %{name: "Signup User", email: "signup_user@mail.com"},
    "credential" => %{source: "password", token: "password"}
  }
  @invalid_attrs %{
    "church" => %{name: nil, slug: nil},
    "user" => %{name: nil, email: nil},
    "credential" => %{source: nil, token: nil}
  }

  describe "new signup" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.signup_path(conn, :new))

      assert html_response(conn, 200) =~ "Sign up"
    end
  end

  describe "create user, church and credentials" do
    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, Routes.signup_path(conn, :create), registration: @create_attrs)

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index, "signup_church")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.signup_path(conn, :create), registration: @invalid_attrs)

      assert html_response(conn, 200) =~ "Sign up"
    end
  end
end
