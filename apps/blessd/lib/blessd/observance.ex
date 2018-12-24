defmodule Blessd.Observance do
  @moduledoc """
  The Observance context.
  """

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Shared
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
    with {:ok, query} <- Shared.authorize(Meeting, current_user) do
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
    with {:ok, query} <- Shared.authorize(Meeting, current_user), do: Repo.find(query, id)
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
    with {:ok, meeting} <- Shared.authorize(meeting, current_user) do
      meeting
      |> Meeting.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a Meeting.
  """
  def delete_meeting(%Meeting{} = meeting, current_user) do
    with {:ok, meeting} <- Shared.authorize(meeting, current_user), do: Repo.delete(meeting)
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
    Shared.authorize(
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
    with {:ok, meeting} <- Shared.authorize(meeting, current_user) do
      {:ok, Meeting.changeset(meeting, %{})}
    end
  end

  @doc """
  List meeting occurrences.
  """
  def list_meeting_occurrences(user, opts \\ [])

  def list_meeting_occurrences(user, opts) when is_list(opts) do
    list_meeting_occurrences(user, Enum.into(opts, %{filter: []}))
  end

  def list_meeting_occurrences(user, %{filter: filter}) do
    with {:ok, query} <- Shared.authorize(MeetingOccurrence, user) do
      query
      |> MeetingOccurrence.preload()
      |> MeetingOccurrence.apply_filter(filter)
      |> Repo.list()
    end
  end

  @doc """
  Gets a single meeting occurrence.
  """
  def find_occurrence(id, current_user) do
    with {:ok, query} <- Shared.authorize(MeetingOccurrence, current_user) do
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
    with {:ok, occurrence} <- Shared.authorize(occurrence, current_user) do
      occurrence
      |> MeetingOccurrence.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a Meeting occurrence.
  """
  def delete_occurrence(%MeetingOccurrence{} = occurrence, current_user) do
    with {:ok, occurrence} <- Shared.authorize(occurrence, current_user),
         do: Repo.delete(occurrence)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking meeting occurrence changes.
  """
  def change_occurrence(%MeetingOccurrence{} = occurrence, current_user) do
    with {:ok, occurrence} <- Shared.authorize(occurrence, current_user) do
      {:ok, MeetingOccurrence.changeset(occurrence, %{})}
    end
  end

  @doc """
  Builds a meeting occurrence to insert.
  """
  # TODO - we should consider user's timezone here
  def new_occurrence(current_user, meeting_id \\ nil, date \\ Date.utc_today()) do
    Shared.authorize(
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
  def list_people(user, opts \\ [])

  def list_people(user, opts) when is_list(opts) do
    list_people(user, Enum.into(opts, %{occurrence: nil, filter: nil, search: nil}))
  end

  def list_people(user, %{occurrence: occurrence, filter: filter, search: search}) do
    with {:ok, query} <- Shared.authorize(Person, user) do
      query
      |> Person.preload()
      |> Person.apply_filter(filter, occurrence)
      |> Person.search(search)
      |> Person.order()
      |> Repo.list()
    end
  end

  @doc """
  Returns a person by its id.
  """
  def find_person(id, current_user) do
    with {:ok, query} <- Shared.authorize(Person, current_user) do
      query
      |> Person.preload()
      |> Repo.find(id)
    end
  end

  @doc """
  Returns the stats from the given occurence attendance.
  """
  def attendance_stats(%MeetingOccurrence{} = occ, user) do
    with {:ok, pq} <- Shared.authorize(Person, user),
         {:ok, aq} <- Shared.authorize(Attendant, user) do
      {:ok, attendance_stats(occ, pq, aq)}
    end
  end

  defp attendance_stats(%MeetingOccurrence{} = occ, pq, aq) do
    total = count_people(pq, occ.date)
    present = count_present(aq, occ, true)
    absent = count_present(aq, occ, false)
    visitors = count_visitors(aq, occ)
    unknown = count_unknown(pq, occ)

    %{
      present: present,
      absent: absent,
      first_time: visitors,
      recurrent: present - visitors,
      total: total,
      unknown: unknown,
      missing: unknown + absent
    }
  end

  defp count_unknown(query, occ) do
    query
    |> Person.unknown_attendance(occ)
    |> select([p], count(p.id))
    |> Repo.one()
  end

  defp count_people(query, date) do
    {:ok, end_of_day} = NaiveDateTime.new(date, ~T[23:59:59])

    query
    |> where([p], p.inserted_at <= ^end_of_day)
    |> select([p], count(p.id))
    |> Repo.one()
  end

  defp count_present(query, %MeetingOccurrence{id: occ_id}, present) do
    query
    |> join(:left, [a], p in assoc(a, :person))
    |> where([a, p], a.present == ^present and a.meeting_occurrence_id == ^occ_id)
    |> select([a, p], count(a.id))
    |> Repo.one()
  end

  defp count_visitors(query, %MeetingOccurrence{id: occ_id}) do
    query
    |> where([a], a.first_time_visitor == true and a.meeting_occurrence_id == ^occ_id)
    |> select([a], count(a.id))
    |> Repo.one()
  end

  @doc """
  Updates the state of the given attendant, and returns its person.
  """
  def update_attendant_state(person_id, occurrence_id, "unknown", current_user) do
    with {:ok, attendant} <-
           Repo.find_by(
             Attendant,
             person_id: person_id,
             meeting_occurrence_id: occurrence_id
           ),
         {:ok, attendant} <- Shared.authorize(attendant, current_user),
         {:ok, _} <- Repo.delete(attendant) do
      find_person(person_id, current_user)
    end
  end

  def update_attendant_state(person_id, occurrence_id, state, current_user) do
    params = %{
      person_id: person_id,
      meeting_occurrence_id: occurrence_id,
      present: state in ["recurrent", "first_time"],
      first_time_visitor: state == "first_time"
    }

    case Repo.find_by(Attendant, person_id: person_id, meeting_occurrence_id: occurrence_id) do
      {:ok, attendant} ->
        with {:ok, meeting} <- Shared.authorize(attendant, current_user),
             changeset = Attendant.changeset(meeting, params),
             {:ok, _} <- Repo.update(changeset) do
          find_person(person_id, current_user)
        end

      {:error, :not_found} ->
        with {:ok, attendant} <- new_attendant(current_user),
             changeset = Attendant.changeset(attendant, params),
             {:ok, _} <- Repo.insert(changeset) do
          find_person(person_id, current_user)
        end
    end
  end

  @doc """
  Builds an attendant to insert.
  """
  def new_attendant(current_user) do
    Shared.authorize(%Attendant{church_id: current_user.church.id}, current_user)
  end

  @doc """
  Returns if the given person can be a first time to the given meeting
  """
  def can_be_first_time_visitor?(
        %Person{id: person_id},
        %MeetingOccurrence{meeting_id: meeting_id, id: occurrence_id, date: date}
      ) do
    Attendant
    |> join(:left, [a], p in assoc(a, :person))
    |> join(:left, [a, p], o in assoc(a, :meeting_occurrence))
    |> where(
      [a, p, o],
      a.present == true and o.meeting_id == ^meeting_id and p.id == ^person_id and
        (o.date <= ^date or a.first_time_visitor == true)
    )
    |> order_by([a, p, o], o.date)
    |> select([a, p, o], o.id)
    |> Repo.all()
    |> case do
      [] -> true
      [^occurrence_id] -> true
      _ -> false
    end
  end
end
