defmodule BlessdWeb.CustomFieldControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Custom

  @create_attrs %{name: "some name", type: "string", validations: %{required: true}}
  @update_attrs %{name: "some updated name", type: "date"}
  @invalid_attrs %{name: nil, type: nil}

  def fixture(:custom_field, user) do
    {:ok, custom_field} = Custom.create_field("person", @create_attrs, user)
    custom_field
  end

  describe "index" do
    test "lists all custom_fields", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.custom_field_path(conn, :index, user.church.slug, "person"))

      assert html_response(conn, 200) =~ "New Custom Field"
    end
  end

  describe "new custom_field" do
    test "renders form", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.custom_field_path(conn, :new, user.church.slug, "person"))

      assert html_response(conn, 200) =~ "New Custom Field"
    end
  end

  describe "create custom_field" do
    test "redirects to index when data is valid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.custom_field_path(conn, :create, user.church.slug, "person"),
          field: @create_attrs
        )

      assert redirected_to(conn) =~
               Routes.custom_field_path(conn, :index, user.church.slug, "person")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.custom_field_path(conn, :create, user.church.slug, "person"),
          field: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Custom Field"
    end
  end

  describe "edit custom_field" do
    test "renders form for editing chosen custom_field", %{conn: conn} do
      user = signup()
      custom_field = fixture(:custom_field, user)

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.custom_field_path(conn, :edit, user.church.slug, "person", custom_field))

      assert html_response(conn, 200) =~ "Edit Custom Field"
    end
  end

  describe "update custom_field" do
    test "redirects when data is valid", %{conn: conn} do
      user = signup()
      custom_field = fixture(:custom_field, user)

      resp =
        conn
        |> authenticate(user)
        |> put(Routes.custom_field_path(conn, :update, user.church.slug, "person", custom_field),
          field: @update_attrs
        )

      assert redirected_to(resp) ==
               Routes.custom_field_path(conn, :edit, user.church.slug, "person", custom_field)

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.custom_field_path(conn, :edit, user.church.slug, "person", custom_field))

      assert html_response(resp, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()
      custom_field = fixture(:custom_field, user)

      conn =
        conn
        |> authenticate(user)
        |> put(Routes.custom_field_path(conn, :update, user.church.slug, "person", custom_field),
          field: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Custom Field"
    end
  end

  describe "delete custom_field" do
    test "deletes chosen custom_field", %{conn: conn} do
      user = signup()
      custom_field = fixture(:custom_field, user)

      resp =
        conn
        |> authenticate(user)
        |> delete(
          Routes.custom_field_path(conn, :delete, user.church.slug, "person", custom_field)
        )

      assert redirected_to(resp) ==
               Routes.custom_field_path(conn, :index, user.church.slug, "person")

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.custom_field_path(conn, :edit, user.church.slug, "person", custom_field))

      assert resp.status == 404
    end
  end
end
