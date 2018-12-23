defmodule Blessd.Observance.Attendant do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Shared.Churches.Church
  alias Blessd.Observance.Person
  alias Blessd.Observance.MeetingOccurrence

  schema "attendants" do
    belongs_to(:church, Church)

    belongs_to(:meeting_occurrence, MeetingOccurrence)
    belongs_to(:person, Person)

    field(:present, :boolean)
    field(:first_time_visitor, :boolean)

    timestamps()
  end

  @doc false
  def changeset(attendant, attrs) do
    attendant
    |> cast(attrs, [:meeting_occurrence_id, :person_id, :present, :first_time_visitor])
    |> basic_validations()
  end

  defp basic_validations(changeset) do
    changeset
    |> validate_required([:meeting_occurrence_id, :person_id, :present])
    |> validate_first_time_visitor()
  end

  defp validate_first_time_visitor(changeset) do
    if get_field(changeset, :first_time_visitor) && !get_field(changeset, :present) do
      add_error(changeset, :first_time_visitor, "can only be true for people that are present")
    else
      changeset
    end
  end

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
    |> join(:inner, [a], p in assoc(a, :meeting_occurrence), as: :meeting_occurrence)
    |> preload([a, person: p, meeting_occurrence: m], person: p, meeting_occurrence: m)
  end
end
