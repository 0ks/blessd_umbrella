defmodule BlessdWeb.PersonControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Memberships

  @create_attrs %{email: "some email", name: "some name", is_member: true}
  @update_attrs %{email: "some updated email", name: "some updated name", is_member: false}
  @invalid_attrs %{email: nil, name: nil, is_member: nil}

  def fixture(:person) do
    {:ok, person} = Memberships.create_person(@create_attrs)
    person
  end

  describe "index" do
    test "lists all people", %{conn: conn} do
      conn = get(conn, person_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing People"
    end
  end

  describe "new person" do
    test "renders form", %{conn: conn} do
      conn = get(conn, person_path(conn, :new))
      assert html_response(conn, 200) =~ "New Person"
    end
  end

  describe "create person" do
    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, person_path(conn, :create), person: @create_attrs)
      assert redirected_to(conn) == person_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, person_path(conn, :create), person: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Person"
    end
  end

  describe "edit person" do
    setup [:create_person]

    test "renders form for editing chosen person", %{conn: conn, person: person} do
      conn = get(conn, person_path(conn, :edit, person))
      assert html_response(conn, 200) =~ "Edit Person"
    end
  end

  describe "update person" do
    setup [:create_person]

    test "redirects when data is valid", %{conn: conn, person: person} do
      conn = put(conn, person_path(conn, :update, person), person: @update_attrs)
      assert redirected_to(conn) == person_path(conn, :index)

      conn = get(conn, person_path(conn, :index))
      assert html_response(conn, 200) =~ "some updated email"
    end

    test "renders errors when data is invalid", %{conn: conn, person: person} do
      conn = put(conn, person_path(conn, :update, person), person: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Person"
    end
  end

  describe "delete person" do
    setup [:create_person]

    test "deletes chosen person", %{conn: conn, person: person} do
      conn = delete(conn, person_path(conn, :delete, person))
      assert redirected_to(conn) == person_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, person_path(conn, :edit, person))
      end)
    end
  end

  defp create_person(_) do
    person = fixture(:person)
    {:ok, person: person}
  end
end
