defmodule Blessd.Observance.Meeting do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Churches.Church
  alias Blessd.Observance.MeetingOccurrence

  schema "meetings" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:description, :string)

    has_many(:occurrences, MeetingOccurrence)

    timestamps()
  end

  @doc false
  def changeset(meeting, attrs) do
    meeting
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end

  @doc false
  def preload(query) do
    occurrences_query = MeetingOccurrence.order(MeetingOccurrence)

    preload(query, [s], occurrences: ^occurrences_query)
  end

  @doc false
  def order(query), do: order_by(query, [s], desc: s.name)
end
