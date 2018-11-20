defmodule Blessd.Observance do
  @moduledoc """
  The Observance context.
  """

  import Ecto.Changeset

  alias Blessd.Auth
  alias Blessd.Observance.Person
  alias Blessd.Observance.Meeting
  alias Blessd.Observance.MeetingOccurrence
  alias Blessd.Observance.Attendant
  alias Blessd.Repo
  alias Ecto.Multi

  @doc """
  Returns the list of meetings.
  """
  def list_meetings(current_user) do
    with {:ok, query} <- Auth.check(Meeting, current_user) do
      query
      |> Meeting.preload()
      |> Meeting.order()
      |> Repo.list()
    end
  end

  @doc """
  Gets a single meeting.
  """
  def find_meeting(id, current_user) do
    with {:ok, query} <- Auth.check(Meeting, current_user), do: Repo.find(query, id)
  end

  @doc """
  Creates a meeting.
  """
  def create_meeting(attrs, current_user) do
    with {:ok, meeting} <- new_meeting(current_user, []),
         changeset = Meeting.changeset(meeting, attrs) do
      Multi.new()
      |> Multi.insert(:meeting, changeset)
      |> Multi.run(
        :occurrence,
        &insert_occurrence(&1, &2, attrs["occurrences"]["0"], current_user)
      )
      |> Repo.transaction()
      |> case do
        {:ok, %{meeting: meeting, occurrence: occurrence}} ->
          {:ok, %{meeting | occurrences: [occurrence]}}

        {:error, :meeting, changeset, _} ->
          {:error, changeset}

        {:error, assoc, %Ecto.Changeset{} = child_changeset, _} ->
          changeset
          |> put_assoc(assoc, child_changeset)
          |> apply_action(:insert)

        {:error, _, reason, _} ->
          {:error, reason}
      end
    end
  end

  @doc """
  Updates a meeting.
  """
  def update_meeting(%Meeting{} = meeting, attrs, current_user) do
    with {:ok, meeting} <- Auth.check(meeting, current_user) do
      meeting
      |> Meeting.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a Meeting.
  """
  def delete_meeting(%Meeting{} = meeting, current_user) do
    with {:ok, meeting} <- Auth.check(meeting, current_user), do: Repo.delete(meeting)
  end

  @doc """
  Builds a meeting to insert.
  """
  def new_meeting(current_user) do
    with {:ok, occurrence} <- new_occurrence(current_user) do
      new_meeting(current_user, [occurrence])
    end
  end

  def new_meeting(current_user, occurrences) do
    Auth.check(
      %Meeting{
        church_id: current_user.church.id,
        occurrences: occurrences
      },
      current_user
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking meeting changes.
  """
  def change_meeting(%Meeting{} = meeting, current_user) do
    with {:ok, meeting} <- Auth.check(meeting, current_user) do
      {:ok, Meeting.changeset(meeting, %{})}
    end
  end

  @doc """
  Gets a single meeting occurrence.
  """
  def find_occurrence(id, current_user) do
    with {:ok, query} <- Auth.check(MeetingOccurrence, current_user) do
      query
      |> MeetingOccurrence.preload()
      |> Repo.find(id)
    end
  end

  @doc """
  Creates a meeting occurrence.
  """
  def create_occurrence(%Meeting{} = meeting, attrs, current_user) do
    insert_occurrence(Repo, meeting, attrs, current_user)
  end

  defp insert_occurrence(repo, %{meeting: meeting}, attrs, current_user) do
    insert_occurrence(repo, meeting, attrs, current_user)
  end

  defp insert_occurrence(repo, %Meeting{id: meeting_id}, attrs, current_user) do
    with {:ok, occurrence} <- new_occurrence(current_user, meeting_id, nil) do
      occurrence
      |> MeetingOccurrence.changeset(attrs)
      |> repo.insert()
    end
  end

  @doc """
  Updates a meeting occurrence.
  """
  def update_occurrence(%MeetingOccurrence{} = occurrence, attrs, current_user) do
    with {:ok, occurrence} <- Auth.check(occurrence, current_user) do
      occurrence
      |> MeetingOccurrence.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a Meeting occurrence.
  """
  def delete_occurrence(%MeetingOccurrence{} = occurrence, current_user) do
    with {:ok, occurrence} <- Auth.check(occurrence, current_user), do: Repo.delete(occurrence)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking meeting occurrence changes.
  """
  def change_occurrence(%MeetingOccurrence{} = occurrence, current_user) do
    with {:ok, occurrence} <- Auth.check(occurrence, current_user) do
      {:ok, MeetingOccurrence.changeset(occurrence, %{})}
    end
  end

  @doc """
  Builds a meeting occurrence to insert.
  """
  # TODO - we should consider user's timezone here
  def new_occurrence(current_user, meeting_id \\ nil, date \\ Date.utc_today()) do
    Auth.check(
      %MeetingOccurrence{
        church_id: current_user.church.id,
        meeting_id: meeting_id,
        date: date
      },
      current_user
    )
  end

  @doc """
  Returns the list of people with their attendants preloaded.
  """
  def list_people(current_user) do
    with {:ok, query} <- Auth.check(Person, current_user) do
      query
      |> Person.preload()
      |> Person.order()
      |> Repo.list()
    end
  end

  @doc """
  Search for people and preload their attendants.
  """
  def search_people(query_str, current_user) do
    with {:ok, query} <- Auth.check(Person, current_user) do
      query
      |> Person.preload()
      |> Person.order()
      |> Person.search(query_str)
      |> Repo.list()
    end
  end

  @doc """
  Creates an attendant if it does not exists and removes it if it exists.
  """
  def toggle_attendant(person_id, occurrence_id, current_user) do
    case Repo.find_by(Attendant, person_id: person_id, meeting_occurrence_id: occurrence_id) do
      {:ok, attendant} ->
        with {:ok, attendant} <- Auth.check(attendant, current_user), do: Repo.delete(attendant)

      {:error, :not_found} ->
        with {:ok, attendant} <- new_attendant(current_user) do
          attendant
          |> Attendant.changeset(%{person_id: person_id, meeting_occurrence_id: occurrence_id})
          |> Repo.insert()
        end
    end
  end

  @doc """
  Builds an attendant to insert.
  """
  def new_attendant(current_user) do
    Auth.check(%Attendant{church_id: current_user.church.id}, current_user)
  end
end
