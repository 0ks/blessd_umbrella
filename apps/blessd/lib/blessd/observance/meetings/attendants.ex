defmodule Blessd.Observance.Meetings.Attendants do
  @moduledoc """
  Secondary context for meeting attendants
  """

  import Ecto.Query

  alias Blessd.Observance.People
  alias Blessd.Observance.People.Person
  alias Blessd.Observance.Meetings.Attendants.Attendant
  alias Blessd.Observance.Meetings.Occurrences
  alias Blessd.Observance.Meetings.Occurrences.Occurrence
  alias Blessd.Repo
  alias Blessd.Shared

  @doc false
  def stats(%Occurrence{} = occ, user) do
    with {:ok, pq} <- Shared.authorize(Person, user),
         {:ok, aq} <- Shared.authorize(Attendant, user) do
      {:ok, stats(occ, pq, aq)}
    end
  end

  defp stats(%Occurrence{} = occ, pq, aq) do
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
    |> People.unknown_attendance(occ)
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

  defp count_present(query, %Occurrence{id: occ_id}, present) do
    query
    |> join(:left, [a], p in assoc(a, :person))
    |> where([a, p], a.present == ^present and a.occurrence_id == ^occ_id)
    |> select([a, p], count(a.id))
    |> Repo.one()
  end

  defp count_visitors(query, %Occurrence{id: occ_id}) do
    query
    |> where([a], a.first_time_visitor == true and a.occurrence_id == ^occ_id)
    |> select([a], count(a.id))
    |> Repo.one()
  end

  def update_state(person_id, occurrence_id, "unknown", current_user) do
    with {:ok, attendant} <-
           Repo.find_by(
             Attendant,
             person_id: person_id,
             occurrence_id: occurrence_id
           ),
         {:ok, attendant} <- Shared.authorize(attendant, current_user),
         {:ok, _} <- Repo.delete(attendant),
         {:ok, occurrence} <- Occurrences.find(occurrence_id, current_user) do
      People.find(person_id, current_user, occurrence: occurrence)
    end
  end

  def update_state(person_id, occurrence_id, state, current_user) do
    params = %{
      person_id: person_id,
      occurrence_id: occurrence_id,
      present: state in ["recurrent", "first_time"],
      first_time_visitor: state == "first_time"
    }

    {attendant, repo_func} =
      case Repo.find_by(Attendant, person_id: person_id, occurrence_id: occurrence_id) do
        {:ok, attendant} -> {attendant, &Repo.update/1}
        {:error, :not_found} -> {build(current_user), &Repo.insert/1}
      end

    with {:ok, attendant} <- Shared.authorize(attendant, current_user),
         changeset = Attendant.changeset(attendant, params),
         {:ok, _} <- repo_func.(changeset),
         {:ok, occurrence} <- Occurrences.find(occurrence_id, current_user) do
      People.find(person_id, current_user, occurrence: occurrence)
    end
  end

  @doc false
  def build(current_user), do: %Attendant{church_id: current_user.church.id}

  @doc false
  def order(query) do
    if has_named_binding?(query, :person) do
      order_by(query, [a, person: p], p.name)
    else
      order_by(query, [a], a.inserted_at)
    end
  end

  @doc false
  def preload(query) do
    query
    |> join(:inner, [a], p in assoc(a, :person), as: :person)
    |> join(:inner, [a], p in assoc(a, :occurrence), as: :occurrence)
    |> preload([a, person: p, occurrence: o], person: p, occurrence: o)
  end
end
