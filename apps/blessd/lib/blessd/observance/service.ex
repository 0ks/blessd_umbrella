defmodule Blessd.Observance.Service do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Observance.ServiceAttendant
  alias Blessd.Service.Validations

  schema "services" do
    field(:name, :string)
    field(:date, :date)

    has_many(:attendants, ServiceAttendant)

    timestamps()
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [:name, :date])
    |> cast_assoc(:attendants, update: :replace)
    |> Validations.basic()
  end
end
