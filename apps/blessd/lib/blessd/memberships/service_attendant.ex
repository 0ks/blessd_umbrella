defmodule Blessd.Memberships.ServiceAttendant do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Memberships.Person
  alias Blessd.Memberships.Service
  alias Blessd.ServiceAttendant.Validations

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
    |> Validations.basic()
  end
end
