defmodule Blessd.Observance do
  @moduledoc """
  The Observance context.
  """

  alias Blessd.Auth
  alias Blessd.Observance.Person
  alias Blessd.Observance.Meeting
  alias Blessd.Observance.Attendant
  alias Blessd.Repo

  @doc """
  Returns the list of meetings.
  """
  def list_meetings(current_user) do
    Meeting
    |> Auth.check!(current_user)
    |> Meeting.order()
    |> Repo.all()
  end

  @doc """
  Gets a single meeting.

  Raises `Ecto.NoResultsError` if the Meeting does not exist.
  """
  def get_meeting!(id, current_user) do
    Meeting
    |> Auth.check!(current_user)
    |> Meeting.order()
    |> Repo.get!(id)
  end

  @doc """
  Creates a meeting.
  """
  def create_meeting(attrs, current_user) do
    current_user
    |> new_meeting()
    |> Meeting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a meeting.
  """
  def update_meeting(%Meeting{} = meeting, attrs, current_user) do
    meeting
    |> Auth.check!(current_user)
    |> Meeting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Meeting.
  """
  def delete_meeting(%Meeting{} = meeting, current_user) do
    meeting
    |> Auth.check!(current_user)
    |> Repo.delete()
  end

  @doc """
  Builds a meeting to insert.
  """
  def new_meeting(current_user) do
    Auth.check!(%Meeting{church_id: current_user.church.id}, current_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking meeting changes.
  """
  def change_meeting(%Meeting{} = meeting, current_user) do
    meeting
    |> Auth.check!(current_user)
    |> Meeting.changeset(%{})
  end

  @doc """
  Returns the list of people with their attendants preloaded.
  """
  def list_people(current_user) do
    Person
    |> Auth.check!(current_user)
    |> Person.preload()
    |> Person.order()
    |> Repo.all()
  end

  @doc """
  Search for people and preload their attendants.
  """
  def search_people(query, current_user) do
    Person
    |> Auth.check!(current_user)
    |> Person.preload()
    |> Person.order()
    |> Person.search(query)
    |> Repo.all()
  end

  @doc """
  Creates an attendant if it does not exists and removes it if it exists.
  """
  def toggle_attendant(person_id, meeting_id, current_user) do
    case Repo.get_by(Attendant, person_id: person_id, meeting_id: meeting_id) do
      nil ->
        current_user
        |> new_attendant()
        |> Attendant.changeset(%{person_id: person_id, meeting_id: meeting_id})
        |> Repo.insert()

      %Attendant{} = attendant ->
        attendant
        |> Auth.check!(current_user)
        |> Repo.delete()
    end
  end

  @doc """
  Builds an attendant to insert.
  """
  def new_attendant(current_user) do
    Auth.check!(%Attendant{church_id: current_user.church.id}, current_user)
  end
end
