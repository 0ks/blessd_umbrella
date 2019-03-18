defmodule BlessdWeb.PersonControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Memberships
  alias Blessd.Signup

  @create_attrs %{email: "some@email.com", name: "some name", is_member: true}
  @update_attrs %{email: "updated@email.com", name: "some updated name", is_member: false}
  @invalid_attrs %{email: nil, name: nil, is_member: nil}

  @signup_attrs %{
    "church" => %{name: "Test Church", slug: "test_church", timezone: "UTC"},
    "user" => %{name: "Test User", email: "test_user@mail.com"},
    "credential" => %{source: "password", token: "password"}
  }

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
        |> get(Routes.person_path(conn, :index, user.church.slug))

      assert html_response(conn, 200) =~ "Listing People"
    end

    test "redirects to dashboard when uncofirmed", %{conn: conn} do
      {:ok, user} = Signup.register(@signup_attrs)

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.person_path(conn, :index, user.church.slug))

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index, user.church.slug)
      assert get_flash(conn, :error) == """
      You must confirm your email first. Please check your inbox,
      request another email or change to a correct email address.
      """
    end
  end

  describe "new person" do
    test "renders form", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.person_path(conn, :new, user.church.slug))

      assert html_response(conn, 200) =~ "New Person"
    end
  end

  describe "create person" do
    test "redirects to index when data is valid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.person_path(conn, :create, user.church.slug), person: @create_attrs)

      assert redirected_to(conn) == Routes.person_path(conn, :index, user.church.slug)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.person_path(conn, :create, user.church.slug), person: @invalid_attrs)

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
        |> get(Routes.person_path(conn, :edit, user.church.slug, person))

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
        |> put(Routes.person_path(conn, :update, user.church.slug, person),
          person: @update_attrs
        )

      assert redirected_to(resp) == Routes.person_path(conn, :index, user.church.slug)

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.person_path(conn, :index, user.church.slug))

      assert html_response(resp, 200) =~ "updated@email.com"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()
      person = fixture(:person, user)

      conn =
        conn
        |> authenticate(user)
        |> put(Routes.person_path(conn, :update, user.church.slug, person),
          person: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Person"
    end
  end

  describe "delete person" do
    test "deletes chosen person", %{conn: conn} do
      user = signup()
      person = fixture(:person, user)

      resp =
        conn
        |> authenticate(user)
        |> delete(Routes.person_path(conn, :delete, user.church.slug, person))

      assert redirected_to(resp) == Routes.person_path(conn, :index, user.church.slug)

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.person_path(conn, :edit, user.church.slug, person))

      assert resp.status == 404
    end
  end
end
