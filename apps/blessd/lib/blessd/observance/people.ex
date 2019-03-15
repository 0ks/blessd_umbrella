defmodule Blessd.Observance.People do
  @moduledoc """
  Secondary context for people from inside observance context
  """

  import Ecto.Query

  alias Blessd.Observance.Meetings.Occurrences.Occurrence
  alias Blessd.Observance.People.Person
  alias Blessd.Repo
  alias Blessd.Shared

  @default_list_opts %{
    filter: nil,
    order: nil,
    search: nil,
    occurrence: nil,
    date: nil,
    meeting_id: nil,
    limit: nil
  }

  @doc false
  def list(user, opts) when is_list(opts) do
    %{
      filter: filter,
      search: search,
      occurrence: occurrence,
      date: date,
      meeting_id: meeting_id,
      limit: limit
    } = Enum.into(opts, @default_list_opts)

    with {:ok, query} <- Shared.authorize(Person, user),
         {:ok, people} <-
           query
           |> preload()
           |> apply_filter(filter, occurrence)
           |> search(search)
           |> order()
           |> apply_limit(filter, limit)
           |> Repo.list() do
      missing = missing(date, meeting_id, filter)
      people =
        people
        |> populate_virtual_fields(occurrence, missing)
        |> order_by_virtual_fields(filter)
        |> limit_by_virtual_fields(filter, limit)

      {:ok, people}
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

  defp populate_virtual_fields(people, occurrence, missing \\ %{})

  defp populate_virtual_fields(people, occurrence, missing) when is_list(people) do
    Enum.map(people, &populate_virtual_fields(&1, occurrence, missing))
  end

  defp populate_virtual_fields(person, occurrence, missing) do
    %{
      person
      | state: state(person, occurrence),
        already_visited: already_visited?(person, occurrence),
        missed: Map.get(missing, person.id, 0)
    }
  end

  defp order_by_virtual_fields(people, "missed") do
    Enum.sort_by(people, & &1.missed, &>=/2)
  end

  defp order_by_virtual_fields(people, _), do: people

  defp limit_by_virtual_fields(people, _, nil), do: people

  defp limit_by_virtual_fields(people, "missed", limit) do
    Enum.take(people, limit)
  end

  defp limit_by_virtual_fields(people, _, _), do: people

  defp state(_, nil), do: nil

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

  defp already_visited?(_, nil), do: nil

  defp already_visited?(%Person{attendants: attendants}, occurrence) do
    Enum.count(attendants, &already_visited?(&1, occurrence)) > 0
  end

  defp already_visited?(attendant, %Occurrence{id: oid, meeting_id: mid, date: date}) do
    attendant.present and attendant.occurrence_id != oid and
      attendant.occurrence.meeting_id == mid and
      (attendant.occurrence.date <= date or attendant.first_time_visitor)
  end

  defp missing(date, meeting_id, _) when nil in [date, meeting_id], do: %{}

  defp missing(date, meeting_id, "missed") do
    occurrence_ids =
      Occurrence
      |> where([o], o.date <= ^date and o.meeting_id == ^meeting_id)
      |> select([o], o.id)
      |> Repo.all()

    # TODO there is N + 1 queries here, one for each occurrence of that meeting
    occurrence_ids
    |> Stream.flat_map(&missing/1)
    |> Enum.reduce(%{}, fn id, result ->
      Map.update(result, id, 1, &(&1 + 1))
    end)
  end

  defp missing(_, _, _), do: %{}

  defp missing(occurrence_id) do
    Person
    |> join(:full, [p], a in assoc(p, :attendants), as: :attendants)
    |> where(
      [p, attendants: a],
        (fragment(
           "NOT EXISTS(?)",
           fragment(
             "SELECT * FROM attendants AS a WHERE a.occurrence_id = ? AND a.person_id = ?",
             ^occurrence_id,
             p.id
           )
         ) or (a.occurrence_id == ^occurrence_id and a.present == false))
    )
    |> select([p, attendants: a], p.id)
    |> Repo.all()
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
  def apply_limit(query, _, nil), do: query
  def apply_limit(query, "missed", _), do: query
  def apply_limit(query, _, limit), do: limit(query, ^limit)

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
