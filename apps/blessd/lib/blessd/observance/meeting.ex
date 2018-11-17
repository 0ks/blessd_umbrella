defmodule Blessd.Observance.Meeting do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Observance.Attendant

  schema "meetings" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:description, :string)
    field(:date, :date)

    has_many(:attendants, Attendant)

    timestamps()
  end

  @doc false
  def changeset(meeting, attrs) do
    meeting
    |> cast(attrs, [:name, :description, :date])
    |> validate_required([:name, :date])
  end

  @doc false
  def order(query), do: order_by(query, [s], desc: s.name)
end
