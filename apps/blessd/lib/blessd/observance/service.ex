defmodule Blessd.Observance.Service do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Observance.ServiceAttendant
  alias Blessd.Service.Validations

  schema "services" do
    field(:date, :date)

    has_many(:attendants, ServiceAttendant)

    timestamps()
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [:date])
    |> Validations.basic()
  end
end
