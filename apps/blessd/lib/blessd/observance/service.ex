defmodule Blessd.Observance.Service do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Observance.ServiceAttendant

  schema "services" do
    belongs_to(:church, Church)

    field(:date, :date)

    has_many(:attendants, ServiceAttendant)

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

  @doc false
  def preload(query) do
    attendants_query =
      ServiceAttendant
      |> ServiceAttendant.preload()
      |> ServiceAttendant.order_preloaded()

    preload(query, attendants: ^attendants_query)
  end
end
