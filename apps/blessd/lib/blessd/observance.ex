defmodule Blessd.Observance do
  @moduledoc """
  The Observance context.
  """

  alias Blessd.Observance.Meetings
  alias Blessd.Observance.Meetings.Occurrences
  alias Blessd.Observance.Meetings.Attendants
  alias Blessd.Observance.People

  @doc """
  Returns the list of meetings.
  """
  def list_meetings(current_user, opts \\ []), do: Meetings.list(current_user, opts)

  @doc """
  Gets a single meeting.
  """
  def find_meeting(id, current_user), do: Meetings.find(id, current_user)

  @doc """
  Creates a meeting.
  """
  def create_meeting(attrs, current_user), do: Meetings.create(attrs, current_user)

  @doc """
  Updates a meeting.
  """
  def update_meeting(meeting, attrs, user), do: Meetings.update(meeting, attrs, user)

  @doc """
  Deletes a Meeting.
  """
  def delete_meeting(meeting, current_user), do: Meetings.delete(meeting, current_user)

  @doc """
  Builds a meeting changeset to insert.
  """
  def new_meeting_changeset(current_user), do: Meetings.new_changeset(current_user)

  @doc """
  Builds a meeting changeset to update.
  """
  def edit_meeting_changeset(id, current_user), do: Meetings.edit_changeset(id, current_user)

  @doc """
  List meeting occurrences.
  """
  def list_occurrences(user, opts \\ []), do: Occurrences.list(user, opts)

  @doc """
  Gets a single meeting occurrence.
  """
  def find_occurrence(id, current_user), do: Occurrences.find(id, current_user)

  @doc """
  Creates a meeting occurrence.
  """
  def create_occurrence(meeting, attrs, user), do: Occurrences.create(meeting, attrs, user)

  @doc """
  Updates a meeting occurrence.
  """
  def update_occurrence(id, attrs, current_user), do: Occurrences.update(id, attrs, current_user)

  @doc """
  Deletes a Meeting occurrence.
  """
  def delete_occurrence(id, current_user), do: Occurrences.delete(id, current_user)

  @doc """
  Builds a meeting changeset to insert.
  """
  def new_occurrence_changeset(meeting_id, user), do: Occurrences.new_changeset(meeting_id, user)

  @doc """
  Builds a meeting changeset to update.
  """
  def edit_occurrence_changeset(id, user), do: Occurrences.edit_changeset(id, user)

  @doc """
  Returns the list of people with their attendants preloaded.
  """
  def list_people(user, opts \\ []), do: People.list(user, opts)

  @doc """
  Returns the stats from the given occurence attendance.
  """
  def attendance_stats(occ, user), do: Attendants.stats(occ, user)

  @doc """
  Updates the state of the given attendant, and returns its person.
  """
  def update_attendant_state(person_id, occurrence_id, state, current_user) do
    Attendants.update_state(person_id, occurrence_id, state, current_user)
  end
end
