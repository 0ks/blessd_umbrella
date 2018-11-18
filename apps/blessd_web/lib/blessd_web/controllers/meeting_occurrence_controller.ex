defmodule BlessdWeb.MeetingOccurrenceController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def new(conn, %{"meeting_id" => meeting_id}) do
    user = conn.assigns.current_user
    meeting = Observance.get_meeting!(meeting_id, user)

    changeset =
      user
      |> Observance.new_occurrence(meeting.id)
      |> Observance.change_occurrence(user)

    render(conn, "new.html", changeset: changeset, meeting: meeting)
  end

  def create(conn, %{"meeting_id" => meeting_id, "meeting_occurrence" => occurrence_params}) do
    user = conn.assigns.current_user
    meeting = Observance.get_meeting!(meeting_id, user)

    case Observance.create_occurrence(meeting, occurrence_params, user) do
      {:ok, _occurrence} ->
        conn
        |> put_flash(:info, gettext("Occurrence created successfully."))
        |> redirect(to: Routes.meeting_path(conn, :index, user.church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, meeting: meeting)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    changeset =
      id
      |> Observance.get_occurrence!(user)
      |> Observance.change_occurrence(user)

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "meeting_occurrence" => occurrence_params}) do
    user = conn.assigns.current_user
    occurrence = Observance.get_occurrence!(id, user)

    case Observance.update_occurrence(occurrence, occurrence_params, user) do
      {:ok, _occurrence} ->
        conn
        |> put_flash(:info, gettext("Occurrence updated successfully."))
        |> redirect(to: Routes.meeting_path(conn, :index, user.church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    occurrence = Observance.get_occurrence!(id, user)
    {:ok, _occurrence} = Observance.delete_occurrence(occurrence, user)

    conn
    |> put_flash(:info, gettext("Occurrence deleted successfully."))
    |> redirect(to: Routes.meeting_path(conn, :index, user.church.identifier))
  end
end
