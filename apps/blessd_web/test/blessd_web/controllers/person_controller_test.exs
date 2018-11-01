defmodule BlessdWeb.PersonControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Memberships

  @create_attrs %{email: "some@email.com", name: "some name", is_member: true}
  @update_attrs %{email: "updated@email.com", name: "some updated name", is_member: false}
  @invalid_attrs %{email: nil, name: nil, is_member: nil}

  def fixture(:person, user) do
    {:ok, person} = Memberships.create_person(@create_attrs, user)
    person
  end

  describe "index" do
    test "lists all people", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(person_path(conn, :index, user.church.identifier))

      assert html_response(conn, 200) =~ "Listing People"
    end
  end

  describe "new person" do
    test "renders form", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(person_path(conn, :new, user.church.identifier))

      assert html_response(conn, 200) =~ "New Person"
    end
  end

  describe "create person" do
    test "redirects to index when data is valid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(person_path(conn, :create, user.church.identifier), person: @create_attrs)

      assert redirected_to(conn) == person_path(conn, :index, user.church.identifier)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(person_path(conn, :create, user.church.identifier), person: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Person"
    end
  end

  describe "edit person" do
    test "renders form for editing chosen person", %{conn: conn} do
      user = signup()
      person = fixture(:person, user)

      conn =
        conn
        |> authenticate(user)
        |> get(person_path(conn, :edit, user.church.identifier, person))

      assert html_response(conn, 200) =~ "Edit Person"
    end
  end

  describe "update person" do
    test "redirects when data is valid", %{conn: conn} do
      user = signup()
      person = fixture(:person, user)

      resp =
        conn
        |> authenticate(user)
        |> put(person_path(conn, :update, user.church.identifier, person), person: @update_attrs)

      assert redirected_to(resp) == person_path(conn, :index, user.church.identifier)

      resp =
        conn
        |> authenticate(user)
        |> get(person_path(conn, :index, user.church.identifier))

      assert html_response(resp, 200) =~ "updated@email.com"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()
      person = fixture(:person, user)

      conn =
        conn
        |> authenticate(user)
        |> put(person_path(conn, :update, user.church.identifier, person), person: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Person"
    end
  end

  describe "delete person" do
    test "deletes chosen person", %{conn: conn} do
      user = signup()
      person = fixture(:person, user)

      conn =
        conn
        |> authenticate(user)
        |> delete(person_path(conn, :delete, user.church.identifier, person))

      assert redirected_to(conn) == person_path(conn, :index, user.church.identifier)

      assert_error_sent(404, fn ->
        get(conn, person_path(conn, :edit, user.church.identifier, person))
      end)
    end
  end
end
