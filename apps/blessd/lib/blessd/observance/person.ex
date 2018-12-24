defmodule Blessd.Observance.Person do
  use Ecto.Schema

  import Ecto.Query

  alias Blessd.Observance.Attendant
  alias Blessd.Observance.MeetingOccurrence
  alias Blessd.Observance.Person

  schema "people" do
    field(:church_id, :id)
    field(:email, :string)
    field(:name, :string)
    field(:is_member, :boolean)

    has_many(:attendants, Attendant)

    timestamps()
  end

  def select_ids(query), do: select(query, [p], p.id)

  @doc false
  def order(query), do: order_by(query, [p], p.name)

  @doc false
  def preload(query) do
    query
    |> join(:left, [p], a in assoc(p, :attendants), as: :attendants)
    |> preload([p, attendants: a], attendants: a)
  end

  def state(%Person{attendants: attendants}, %MeetingOccurrence{id: occurrence_id}) do
    case Enum.find(attendants, &(&1.meeting_occurrence_id == occurrence_id)) do
      nil ->
        :unknown

      attendant ->
        case {attendant.present, attendant.first_time_visitor} do
          {true, true} -> :first_time
          {true, false} -> :recurrent
          {false, false} -> :absent
        end
    end
  end

  def search(query, nil), do: query

  def search(query, query_str) do
    query_str = "%#{query_str}%"

    where(
      query,
      [p],
      fragment("? ilike ?", p.name, ^query_str) or fragment("? ilike ?", p.email, ^query_str)
    )
  end

  def by_occurrence(query, nil), do: query

  def by_occurrence(query, %MeetingOccurrence{id: occurrence_id}) do
    where(query, [attendants: a], a.meeting_occurrence_id == ^occurrence_id)
  end

  def apply_filter(query, nil, _), do: query
  def apply_filter(query, "all", _), do: query

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

  def apply_filter(query, "missing", %MeetingOccurrence{id: occ_id} = occ) do
    query
    |> unknown_attendance(occ)
    |> or_where([attendants: a], a.meeting_occurrence_id == ^occ_id and a.present == false)
  end

  def unknown_attendance(query, %MeetingOccurrence{id: occ_id}) do
    where(
      query,
      [p],
      fragment(
        "NOT EXISTS(?)",
        fragment(
          "SELECT * FROM attendants AS a WHERE a.person_id = ? AND a.meeting_occurrence_id = ?",
          p.id,
          ^occ_id
        )
      )
    )
  end
end
