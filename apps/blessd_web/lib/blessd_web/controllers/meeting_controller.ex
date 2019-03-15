defmodule BlessdWeb.MeetingController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, _params) do
    with {:ok, meetings} <- Observance.list_meetings(conn.assigns.current_user) do
      render(conn, "index.html", meetings: meetings)
    end
  end

  def show(conn, %{"id" => id} = params) do
    tab = params["tab"]
    user = conn.assigns.current_user
    with {:ok, meeting} <- Observance.find_meeting(id, user),
         {:ok, missed_people} <- load_missed_people(id, user, tab) do
      render(conn, "show.html", tab: tab, meeting: meeting, missed_people: missed_people)
    end
  end

  defp load_missed_people(id, user, "missed_people") do
    Observance.list_people(user, filter: "missed", date: Date.utc_today(), meeting_id: id)
  end

  defp load_missed_people(_, _, _), do: {:ok, []}

  def new(conn, _params) do
    with {:ok, changeset} <- Observance.new_meeting_changeset(conn.assigns.current_user) do
      render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"meeting" => meeting_params}) do
    with user = conn.assigns.current_user,
         {:ok, _meeting} <- Observance.create_meeting(meeting_params, user) do
      conn
      |> put_flash(:info, gettext("Meeting created successfully."))
      |> redirect(to: Routes.meeting_path(conn, :index, user.church.slug))
    else
      {:error, %Ecto.Changeset{} = changeset} -> render(conn, "new.html", changeset: changeset)
      {:error, reason} -> {:error, reason}
    end
  end

  def edit(conn, %{"id" => id}) do
    with user = conn.assigns.current_user,
         {:ok, changeset} <- Observance.edit_meeting_changeset(id, user) do
      render(conn, "edit.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "meeting" => meeting_params}) do
    with user = conn.assigns.current_user,
         {:ok, _meeting} <- Observance.update_meeting(id, meeting_params, user) do
      conn
      |> put_flash(:info, gettext("Meeting updated successfully."))
      |> redirect(to: Routes.meeting_path(conn, :index, user.church.slug))
    else
      {:error, %Ecto.Changeset{} = changeset} -> render(conn, "edit.html", changeset: changeset)
      {:error, reason} -> {:error, reason}
    end
  end

  def delete(conn, %{"id" => id}) do
    with user = conn.assigns.current_user,
         {:ok, _meeting} = Observance.delete_meeting(id, user) do
      conn
      |> put_flash(:info, gettext("Meeting deleted successfully."))
      |> redirect(to: Routes.meeting_path(conn, :index, user.church.slug))
    end
  end
end
