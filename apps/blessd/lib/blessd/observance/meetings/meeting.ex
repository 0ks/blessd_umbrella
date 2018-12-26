defmodule Blessd.Observance.Meetings.Meeting do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Observance.Meetings.Meeting
  alias Blessd.Observance.Meetings.Occurrences.Occurrence
  alias Blessd.Shared.Churches.Church

  schema "meetings" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:description, :string)

    has_many(:occurrences, Occurrence)

    timestamps()
  end

  @doc false
  def changeset(%Meeting{} = meeting, attrs) do
    meeting
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
