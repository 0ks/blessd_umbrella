defmodule BlessdWeb.ChurchControllerTest do
  use BlessdWeb.ConnCase

  @update_attrs %{name: "some updated name", slug: "some_updated_slug"}
  @invalid_attrs %{name: nil, slug: nil}

  describe "edit church" do
    test "renders form for editing chosen church", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.church_path(conn, :edit, user.church.slug))

      assert html_response(conn, 200) =~ "Church Config"
    end
  end

  describe "update church" do
    test "redirects when data is valid", %{conn: conn} do
      user = signup()

      resp =
        conn
        |> authenticate(user)
        |> put(Routes.church_path(conn, :update, user.church.slug),
          church: @update_attrs
        )

      assert redirected_to(resp) == Routes.church_path(conn, :edit, "some_updated_slug")

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.church_path(conn, :edit, "some_updated_slug"))

      assert html_response(resp, 200) =~ "some_updated_slug"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> put(Routes.church_path(conn, :update, user.church.slug),
          church: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Church Config"
    end
  end

  describe "delete church" do
    test "deletes chosen church", %{conn: conn} do
      user = signup()

      resp =
        conn
        |> authenticate(user)
        |> delete(Routes.church_path(conn, :delete, user.church.slug))

      assert redirected_to(resp) == "/"

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.church_path(conn, :edit, user.church.slug))

      assert redirected_to(resp) == Routes.session_path(conn, :new, church_slug: user.church.slug)
      assert get_flash(resp, :error) == "This page can only be accessed when signed in."
    end
  end
end

