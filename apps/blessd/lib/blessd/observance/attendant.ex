defmodule Blessd.Observance.Attendant do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Observance.Person
  alias Blessd.Observance.MeetingOccurrence

  schema "attendants" do
    belongs_to(:church, Church)

    belongs_to(:meeting_occurrence, MeetingOccurrence)
    belongs_to(:person, Person)

    timestamps()
  end

  @doc false
  def changeset(attendant, attrs) do
    attendant
    |> cast(attrs, [:meeting_occurrence_id, :person_id])
    |> basic_validations()
  end

  defp basic_validations(changeset) do
    validate_required(changeset, [:meeting_occurrence_id, :person_id])
  end

  def order(query) do
    if has_named_binding?(query, :person) do
      order_by(query, [a, person: p], p.name)
    else
      order_by(query, [a], a.inserted_at)
    end
  end

  def preload(query) do
    query
    |> join(:inner, [a], p in assoc(a, :person), as: :person)
    |> join(:inner, [a], p in assoc(a, :meeting_occurrence), as: :meeting_occurrence)
    |> preload([a, person: p, meeting_occurrence: m], person: p, meeting_occurrence: m)
  end
end
