defmodule Blessd.Observance.Meetings.Occurrences.Occurrence do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Shared.Churches.Church
  alias Blessd.Observance.Meetings.Attendants.Attendant
  alias Blessd.Observance.Meetings.Meeting

  schema "meeting_occurrences" do
    belongs_to(:church, Church)

    belongs_to(:meeting, Meeting)
    field(:date, :date)

    has_many(:attendants, Attendant)

    timestamps()
  end

  @doc false
  def changeset(occurrence, attrs) do
    occurrence
    |> cast(attrs, [:date])
    |> validate_required([:meeting_id, :date])
  end
end
