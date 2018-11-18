defmodule BlessdWeb.MeetingOccurrenceControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Observance

  @meeting_attrs %{"name" => "some name", "occurrences" => %{"0" => %{date: ~D[2018-10-10]}}}

  @create_attrs %{date: ~D[2018-10-10]}
  @update_attrs %{date: ~D[2000-01-01]}
  @invalid_attrs %{date: nil}

  def fixture(:meeting, user) do
    {:ok, meeting} = Observance.create_meeting(@meeting_attrs, user)
    meeting
  end

  def fixture(:occurrence, meeting, user) do
    {:ok, meeting} = Observance.create_occurrence(meeting, @create_attrs, user)
    meeting
  end

  describe "new meeting" do
    test "renders form", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.meeting_occurrence_path(conn, :new, user.church.identifier, meeting))

      assert html_response(conn, 200) =~ "New Meeting Occurrence"
    end
  end

  describe "create meeting" do
    test "redirects to index when data is valid", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.meeting_occurrence_path(conn, :create, user.church.identifier, meeting),
          meeting_occurrence: @create_attrs
        )

      assert redirected_to(conn) == Routes.meeting_path(conn, :index, user.church.identifier)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.meeting_occurrence_path(conn, :create, user.church.identifier, meeting),
          meeting_occurrence: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Meeting Occurrence"
    end
  end

  describe "edit meeting" do
    test "renders form for editing chosen meeting", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)
      occurrence = fixture(:occurrence, meeting, user)

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.meeting_occurrence_path(conn, :edit, user.church.identifier, occurrence))

      assert html_response(conn, 200) =~ "Edit Meeting Occurrence"
    end
  end

  describe "update meeting" do
    test "redirects when data is valid", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)
      occurrence = fixture(:occurrence, meeting, user)

      resp =
        conn
        |> authenticate(user)
        |> put(Routes.meeting_occurrence_path(conn, :update, user.church.identifier, occurrence),
          meeting_occurrence: @update_attrs
        )

      assert redirected_to(resp) == Routes.meeting_path(conn, :index, user.church.identifier)

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.meeting_path(conn, :index, user.church.identifier))

      assert html_response(resp, 200) =~ "01/01/2000"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)
      occurrence = fixture(:occurrence, meeting, user)

      conn =
        conn
        |> authenticate(user)
        |> put(Routes.meeting_occurrence_path(conn, :update, user.church.identifier, occurrence),
          meeting_occurrence: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Meeting Occurrence"
    end
  end

  describe "delete meeting" do
    test "deletes chosen meeting", %{conn: conn} do
      user = signup()
      meeting = fixture(:meeting, user)
      occurrence = fixture(:occurrence, meeting, user)

      resp =
        conn
        |> authenticate(user)
        |> delete(
          Routes.meeting_occurrence_path(conn, :delete, user.church.identifier, occurrence)
        )

      assert redirected_to(resp) == Routes.meeting_path(conn, :index, user.church.identifier)

      assert_error_sent(404, fn ->
        conn
        |> authenticate(user)
        |> get(Routes.meeting_occurrence_path(conn, :edit, user.church.identifier, occurrence))
      end)
    end
  end
end
