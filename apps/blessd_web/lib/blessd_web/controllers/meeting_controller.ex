defmodule BlessdWeb.MeetingController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, _params) do
    meetings = Observance.list_meetings(conn.assigns.current_user)
    render(conn, "index.html", meetings: meetings)
  end

  def new(conn, _params) do
    user = conn.assigns.current_user

    changeset =
      user
      |> Observance.new_meeting()
      |> Observance.change_meeting(user)

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"meeting" => meeting_params}) do
    user = conn.assigns.current_user

    case Observance.create_meeting(meeting_params, user) do
      {:ok, _meeting} ->
        conn
        |> put_flash(:info, gettext("Meeting created successfully."))
        |> redirect(to: Routes.meeting_path(conn, :index, user.church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    changeset =
      id
      |> Observance.get_meeting!(user)
      |> Observance.change_meeting(user)

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "meeting" => meeting_params}) do
    user = conn.assigns.current_user
    meeting = Observance.get_meeting!(id, user)

    case Observance.update_meeting(meeting, meeting_params, user) do
      {:ok, _meeting} ->
        conn
        |> put_flash(:info, gettext("Meeting updated successfully."))
        |> redirect(to: Routes.meeting_path(conn, :index, user.church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    meeting = Observance.get_meeting!(id, user)
    {:ok, _meeting} = Observance.delete_meeting(meeting, user)

    conn
    |> put_flash(:info, gettext("Meeting deleted successfully."))
    |> redirect(to: Routes.meeting_path(conn, :index, user.church.identifier))
  end
end
