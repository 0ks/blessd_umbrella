defmodule BlessdWeb.MeetingOccurrenceChannel do
  use BlessdWeb, :channel

  alias Blessd.Memberships
  alias Blessd.Observance
  alias BlessdWeb.MeetingOccurrenceView
  alias Phoenix.View

  def join("meeting_occurrence:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in(
        "search",
        %{"meeting_occurrence_id" => occurrence_id, "query" => query, "filter" => filter},
        socket
      ) do
    with user = socket.assigns.current_user,
         {:ok, occurrence} <- Observance.find_occurrence(occurrence_id, user),
         {:ok, people} <-
           Observance.list_people(user, occurrence: occurrence, filter: filter, search: query) do
      html =
        View.render_to_string(MeetingOccurrenceView, "table_body.html",
          people: people,
          occurrence: occurrence
        )

      {:reply, {:ok, %{table_body: html}}, socket}
    else
      {:error, reason} ->
        {:reply, {:error, error_response(reason)}, socket}
    end
  end

  def handle_in(
        "create",
        %{"person" => person_params, "meeting_occurrence_id" => occurrence_id},
        socket
      ) do
    with user = socket.assigns.current_user,
         {:ok, person} <- Memberships.create_person(person_params, user),
         {:ok, occurrence} <- Observance.find_occurrence(occurrence_id, user),
         {:ok, people} <- Observance.list_people(user, search: person.name) do
      html =
        View.render_to_string(MeetingOccurrenceView, "table_body.html",
          people: people,
          occurrence: occurrence
        )

      {:reply, {:ok, %{table_body: html}}, socket}
    else
      {:error, reason} ->
        {:reply, {:error, error_response(reason)}, socket}
    end
  end

  def handle_in(
        "update_state",
        %{"person_id" => person_id, "meeting_occurrence_id" => occurrence_id, "state" => state},
        socket
      ) do
    with user = socket.assigns.current_user,
         {:ok, occurrence} <- Observance.find_occurrence(occurrence_id, user),
         {:ok, person} <-
           Observance.update_attendant_state(
             person_id,
             occurrence_id,
             state,
             user
           ) do
      html =
        View.render_to_string(MeetingOccurrenceView, "table_row.html",
          person: person,
          occurrence: occurrence
        )

      {:reply, {:ok, %{table_row: html}}, socket}
    else
      {:error, reason} ->
        {:reply, {:error, error_response(reason)}, socket}
    end
  end

  defp error_response(%Ecto.Changeset{} = changeset), do: errors_from_changeset(changeset)
  defp error_response(:not_found), do: %{message: "Occurrence not found"}
  defp error_response(:unauthorized), do: %{message: "Unauthorized user"}
  defp error_response(:unconfirmed), do: %{message: "Unconfirmed user"}

  defp errors_from_changeset(%Ecto.Changeset{errors: errors}) do
    errors
    |> Stream.map(fn {field, {msg, _}} -> {field, msg} end)
    |> Enum.into(%{})
  end
end
