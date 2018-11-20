defmodule BlessdWeb.MeetingOccurrenceController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def new(conn, %{"meeting_id" => meeting_id}) do
    with user = conn.assigns.current_user,
         {:ok, meeting} <- Observance.find_meeting(meeting_id, user),
         {:ok, occurrence} <- Observance.new_occurrence(user, meeting.id),
         {:ok, changeset} <- Observance.change_occurrence(occurrence, user) do
      render(conn, "new.html", changeset: changeset, meeting: meeting)
    end
  end

  def create(conn, %{"meeting_id" => meeting_id, "meeting_occurrence" => occurrence_params}) do
    with user = conn.assigns.current_user,
         {:ok, meeting} <- Observance.find_meeting(meeting_id, user) do
      case Observance.create_occurrence(meeting, occurrence_params, user) do
        {:ok, _occurrence} ->
          conn
          |> put_flash(:info, gettext("Occurrence created successfully."))
          |> redirect(to: Routes.meeting_path(conn, :index, user.church.identifier))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset, meeting: meeting)

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    with user = conn.assigns.current_user,
         {:ok, occurrence} <- Observance.find_occurrence(id, user),
         {:ok, changeset} <- Observance.change_occurrence(occurrence, user) do
      render(conn, "edit.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "meeting_occurrence" => occurrence_params}) do
    with user = conn.assigns.current_user,
         {:ok, occurrence} <- Observance.find_occurrence(id, user),
         {:ok, _} <- Observance.update_occurrence(occurrence, occurrence_params, user) do
      conn
      |> put_flash(:info, gettext("Occurrence updated successfully."))
      |> redirect(to: Routes.meeting_path(conn, :index, user.church.identifier))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def delete(conn, %{"id" => id}) do
    with user = conn.assigns.current_user,
         {:ok, occurrence} <- Observance.find_occurrence(id, user),
         {:ok, _occurrence} = Observance.delete_occurrence(occurrence, user) do
      conn
      |> put_flash(:info, gettext("Occurrence deleted successfully."))
      |> redirect(to: Routes.meeting_path(conn, :index, user.church.identifier))
    end
  end
end
