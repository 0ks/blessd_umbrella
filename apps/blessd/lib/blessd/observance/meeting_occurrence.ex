defmodule Blessd.Observance.MeetingOccurrence do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Shared.Churches.Church
  alias Blessd.Observance.Attendant
  alias Blessd.Observance.Meeting

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

  @doc false
  def preload(query), do: preload(query, [o], [:meeting])

  @doc false
  def order(query), do: order_by(query, [o], desc: o.date)
end
