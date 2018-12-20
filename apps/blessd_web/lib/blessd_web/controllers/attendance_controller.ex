defmodule BlessdWeb.AttendanceController do
  use BlessdWeb, :controller

  alias Blessd.Memberships
  alias Blessd.Observance
  alias Blessd.Shared

  def index(conn, %{"meeting_occurrence_id" => occurrence_id} = params) do
    with user = conn.assigns.current_user,
         query = params["search"],
         {:ok, occurrence} <- Observance.find_occurrence(occurrence_id, user),
         {:ok, people} <- list_people(query, user),
         {:ok, person} <- Memberships.new_person(user),
         {:ok, changeset} <- Memberships.change_person(person, user),
         {:ok, fields} <- Shared.list_custom_fields("person", user) do
      render(conn, "index.html",
        occurrence: occurrence,
        people: people,
        changeset: changeset,
        fields: fields,
        query: query
      )
    end
  end

  defp list_people(nil, user), do: Observance.list_people(user)
  defp list_people(query, user), do: Observance.search_people(query, user)

  def create(conn, %{"meeting_occurrence_id" => occurrence_id, "person" => person_params}) do
    with user = conn.assigns.current_user,
         {:ok, person} <- Memberships.create_person(person_params, user),
         {:ok, occurrence} <- Observance.find_occurrence(occurrence_id, user) do
      conn
      |> put_flash(:info, gettext("Visitor successfully created."))
      |> redirect(
        to:
          Routes.meeting_occurrence_attendance_path(
            conn,
            :index,
            user.church.slug,
            occurrence,
            search: person.name
          )
      )
    end
  end
end
