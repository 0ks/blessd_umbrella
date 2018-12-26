defmodule Blessd.Observance.People do
  @moduledoc """
  Secondary context for people from inside observance context
  """

  import Ecto.Query

  alias Blessd.Observance.Meetings.Occurrences.Occurrence
  alias Blessd.Observance.People.Person
  alias Blessd.Repo
  alias Blessd.Shared

  @doc false
  def list(user, opts) when is_list(opts) do
    list(user, Enum.into(opts, %{occurrence: nil, filter: nil, search: nil}))
  end

  def list(user, %{occurrence: occurrence, filter: filter, search: search}) do
    with {:ok, query} <- Shared.authorize(Person, user),
         {:ok, people} <-
           query
           |> preload()
           |> apply_filter(filter, occurrence)
           |> search(search)
           |> order()
           |> Repo.list() do
      {:ok, populate_virtual_fields(people, occurrence)}
    end
  end

  @doc false
  def find(id, user, opts) when is_list(opts) do
    find(id, user, Enum.into(opts, %{occurrence: nil}))
  end

  def find(id, user, %{occurrence: occurrence}) do
    with {:ok, query} <- Shared.authorize(Person, user),
         {:ok, person} <- query |> preload() |> Repo.find(id) do
      {:ok, populate_virtual_fields(person, occurrence)}
    end
  end

  defp populate_virtual_fields(people, nil), do: people

  defp populate_virtual_fields(people, occurrence) when is_list(people) do
    Enum.map(people, &populate_virtual_fields(&1, occurrence))
  end

  defp populate_virtual_fields(person, occurrence) do
    %{
      person
      | state: state(person, occurrence),
        already_visited: already_visited?(person, occurrence)
    }
  end

  defp state(%Person{attendants: attendants}, %Occurrence{id: occurrence_id}) do
    case Enum.find(attendants, &(&1.occurrence_id == occurrence_id)) do
      nil ->
        "unknown"

      attendant ->
        case {attendant.present, attendant.first_time_visitor} do
          {true, true} -> "first_time"
          {true, false} -> "recurrent"
          {false, false} -> "absent"
        end
    end
  end

  defp already_visited?(%Person{attendants: attendants}, occurrence) do
    Enum.count(attendants, &already_visited?(&1, occurrence)) > 0
  end

  defp already_visited?(attendant, %Occurrence{id: oid, meeting_id: mid, date: date}) do
    attendant.present and attendant.occurrence_id != oid and
      attendant.occurrence.meeting_id == mid and
      (attendant.occurrence.date <= date or attendant.first_time_visitor)
  end

  @doc false
  def select_ids(query), do: select(query, [p], p.id)

  @doc false
  def order(query), do: order_by(query, [p], p.name)

  @doc false
  def preload(query) do
    query
    |> join(:left, [p], a in assoc(p, :attendants), as: :attendants)
    |> join(:left, [attendants: a], o in assoc(a, :occurrence))
    |> preload([p, attendants: a], attendants: a)
  end

  @doc false
  def search(query, nil), do: query

  def search(query, query_str) do
    query_str = "%#{query_str}%"

    where(
      query,
      [p],
      fragment("? ilike ?", p.name, ^query_str) or fragment("? ilike ?", p.email, ^query_str)
    )
  end

  @doc false
  def by_occurrence(query, nil), do: query

  def by_occurrence(query, %Occurrence{id: occurrence_id}) do
    where(query, [attendants: a], a.occurrence_id == ^occurrence_id)
  end

  @doc false
  def apply_filter(query, "present", occ) do
    query
    |> by_occurrence(occ)
    |> where([attendants: a], a.present == true)
  end

  def apply_filter(query, "first_time", occ) do
    query
    |> by_occurrence(occ)
    |> where([attendants: a], a.present == true and a.first_time_visitor == true)
  end

  def apply_filter(query, "recurrent", occ) do
    query
    |> by_occurrence(occ)
    |> where([attendants: a], a.present == true and a.first_time_visitor == false)
  end

  def apply_filter(query, "absent", occ) do
    query
    |> by_occurrence(occ)
    |> where([attendants: a], a.present == false)
  end

  def apply_filter(query, "unknown", occ) do
    unknown_attendance(query, occ)
  end

  def apply_filter(query, "missing", %Occurrence{id: occ_id} = occ) do
    query
    |> unknown_attendance(occ)
    |> or_where([attendants: a], a.occurrence_id == ^occ_id and a.present == false)
  end

  def apply_filter(query, _, _), do: query

  @doc false
  def unknown_attendance(query, %Occurrence{id: occ_id}) do
    where(
      query,
      [p],
      fragment(
        "NOT EXISTS(?)",
        fragment(
          "SELECT * FROM attendants AS a WHERE a.person_id = ? AND a.occurrence_id = ?",
          p.id,
          ^occ_id
        )
      )
    )
  end
end
