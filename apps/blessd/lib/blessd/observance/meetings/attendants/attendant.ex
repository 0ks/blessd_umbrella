defmodule Blessd.Observance.Meetings.Attendants.Attendant do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Shared.Churches.Church
  alias Blessd.Observance.People.Person
  alias Blessd.Observance.Meetings.Occurrences.Occurrence

  schema "attendants" do
    belongs_to(:church, Church)

    belongs_to(:occurrence, Occurrence)
    belongs_to(:person, Person)

    field(:present, :boolean)
    field(:first_time_visitor, :boolean)

    timestamps()
  end

  @doc false
  def changeset(attendant, attrs) do
    attendant
    |> cast(attrs, [:occurrence_id, :person_id, :present, :first_time_visitor])
    |> basic_validations()
  end

  defp basic_validations(changeset) do
    changeset
    |> validate_required([:occurrence_id, :person_id, :present])
    |> validate_first_time_visitor()
  end

  defp validate_first_time_visitor(changeset) do
    if get_field(changeset, :first_time_visitor) && !get_field(changeset, :present) do
      add_error(changeset, :first_time_visitor, "can only be true for people that are present")
    else
      changeset
    end
  end
end
