defmodule Blessd.Observance.Service do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Observance.Attendant

  schema "services" do
    belongs_to(:church, Church)

    field(:date, :date)

    has_many(:attendants, Attendant)

    timestamps()
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [:date])
    |> validate_required([:date])
  end

  @doc false
  def order(query), do: order_by(query, [s], desc: s.date)
end
