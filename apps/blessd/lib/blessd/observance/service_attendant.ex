defmodule Blessd.Observance.ServiceAttendant do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Observance.Person
  alias Blessd.Observance.Service

  schema "service_attendants" do
    belongs_to(:service, Service)
    belongs_to(:person, Person)
    field(:is_present, :boolean)

    timestamps()
  end

  @doc false
  def changeset(attendant, attrs) do
    attendant
    |> cast(attrs, [:service_id, :person_id, :is_present])
    |> validate_required([:service_id, :person_id, :is_present])
  end
end
