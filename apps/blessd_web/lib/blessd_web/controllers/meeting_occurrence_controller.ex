defmodule BlessdWeb.MeetingOccurrenceController do
  use BlessdWeb, :controller

  alias Blessd.Observance
  alias Blessd.Memberships
  alias Blessd.Shared

  def show(conn, %{"id" => id} = params) do
    with user = conn.assigns.current_user,
         filter = params["filter"],
         search = params["search"],
         {:ok, occurrence} <- Observance.find_occurrence(id, user),
         {:ok, stats} <- Observance.attendance_stats(occurrence, user),
         {:ok, people} <-
           Observance.list_people(user, occurrence: occurrence, filter: filter, search: search),
         {:ok, person} <- Memberships.new_person(user),
         {:ok, changeset} <- Memberships.change_person(person, user),
         {:ok, fields} <- Shared.list_custom_fields("person", user) do
      render(
        conn,
        "show.html",
        occurrence: occurrence,
        people: people,
        stats: stats,
        filter: filter,
        changeset: changeset,
        fields: fields,
        search: search
      )
    end
  end

  def new(conn, %{"meeting_id" => meeting_id}) do
    with user = conn.assigns.current_user,
         {:ok, meeting} <- Observance.find_meeting(meeting_id, user),
         {:ok, changeset} <- Observance.new_occurrence_changeset(meeting_id, user) do
      render(conn, "new.html", changeset: changeset, meeting: meeting)
    end
  end

  def create(conn, %{"meeting_id" => meeting_id, "occurrence" => occurrence_params}) do
    with user = conn.assigns.current_user,
         {:ok, meeting} <- Observance.find_meeting(meeting_id, user) do
      case Observance.create_occurrence(meeting, occurrence_params, user) do
        {:ok, _occurrence} ->
          conn
          |> put_flash(:info, gettext("Occurrence created successfully."))
          |> redirect(to: Routes.meeting_path(conn, :index, user.church.slug))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset, meeting: meeting)

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, changeset} <- Observance.edit_occurrence_changeset(id, conn.assigns.current_user) do
      render(conn, "edit.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "occurrence" => occurrence_params}) do
    with user = conn.assigns.current_user,
         {:ok, _occurrence} <- Observance.update_occurrence(id, occurrence_params, user) do
      conn
      |> put_flash(:info, gettext("Occurrence updated successfully."))
      |> redirect(to: Routes.meeting_path(conn, :index, user.church.slug))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def delete(conn, %{"id" => id}) do
    with user = conn.assigns.current_user,
         {:ok, _occurrence} = Observance.delete_occurrence(id, user) do
      conn
      |> put_flash(:info, gettext("Occurrence deleted successfully."))
      |> redirect(to: Routes.meeting_path(conn, :index, user.church.slug))
    end
  end
end
