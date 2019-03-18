defmodule BlessdWeb.UserControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Invitation

  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{email: nil, name: nil}

  describe "index" do
    test "lists all users", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.user_path(conn, :index, user.church.slug))

      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "edit user" do
    test "renders form for editing chosen user", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.user_path(conn, :edit, user.church.slug, user))

      assert html_response(conn, 200) =~ "Profile"
    end
  end

  describe "update user" do
    test "redirects when data is valid", %{conn: conn} do
      user = signup()

      resp =
        conn
        |> authenticate(user)
        |> put(Routes.user_path(conn, :update, user.church.slug, user),
          user: @update_attrs
        )

      assert redirected_to(resp) == Routes.user_path(conn, :index, user.church.slug)

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.user_path(conn, :index, user.church.slug))

      assert html_response(resp, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> put(Routes.user_path(conn, :update, user.church.slug, user),
          user: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Profile"
    end
  end

  describe "delete user" do
    test "deletes chosen user", %{conn: conn} do
      user = signup()
      {:ok, new_user} = Invitation.invite(%{email: "new@mail.com"}, user)

      resp =
        conn
        |> authenticate(user)
        |> delete(Routes.user_path(conn, :delete, user.church.slug, new_user))

      assert redirected_to(resp) == Routes.user_path(conn, :index, user.church.slug)

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.user_path(conn, :edit, user.church.slug, new_user))

      assert resp.status == 404
    end
  end
end
