defmodule BlessdWeb.MeetingControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Observance

  @create_attrs %{"name" => "some name", "occurrences" => %{"0" => %{date: ~D[2018-10-10]}}}
  @update_attrs %{"name" => "updated name", "occurrences" => %{"0" => %{date: ~D[2000-01-01]}}}
  @invalid_attrs %{name: nil}

  def fixture(:meeting, user) do
    {:ok, meeting} = Observance.create_meeting(@create_attrs, user)
    meeting
  end

  describe "index" do
    test "lists all meetings", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.meeting_path(conn, :index, user.church.identifier))

      assert html_response(conn, 200) =~ "Listing Meetings"
    end
  end

  describe "new meeting" do
    test "renders form", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.meeting_path(conn, :new, user.church.identifier))

      assert html_response(conn, 200) =~ "New Meeting"
    end
  end

  describe "create meeting" do
    test "redirects to index when data is valid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.meeting_path(conn, :create, user.church.identifier), meeting: @create_attrs)

      assert redirected_to(conn) == Routes.meeting_path(conn, :index, user.church.identifier)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.meeting_path(conn, :create, user.church.identifier),
          meeting: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Meeting"
    end
  end

  describe "edit meeting" do
    test "renders form for editing chosen meeting", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.meeting_path(conn, :edit, user.church.identifier, meeting))

      assert html_response(conn, 200) =~ "Edit Meeting"
    end
  end

  describe "update meeting" do
    test "redirects when data is valid", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)

      resp =
        conn
        |> authenticate(user)
        |> put(Routes.meeting_path(conn, :update, user.church.identifier, meeting),
          meeting: @update_attrs
        )

      assert redirected_to(resp) == Routes.meeting_path(conn, :index, user.church.identifier)

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.meeting_path(conn, :index, user.church.identifier))

      assert html_response(resp, 200) =~ "updated name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)

      conn =
        conn
        |> authenticate(user)
        |> put(Routes.meeting_path(conn, :update, user.church.identifier, meeting),
          meeting: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Meeting"
    end
  end

  describe "delete meeting" do
    test "deletes chosen meeting", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)

      resp =
        conn
        |> authenticate(user)
        |> delete(Routes.meeting_path(conn, :delete, user.church.identifier, meeting))

      assert redirected_to(resp) == Routes.meeting_path(conn, :index, user.church.identifier)

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.meeting_path(conn, :edit, user.church.identifier, meeting))

      assert resp.status == 404
    end
  end
end
