defmodule Blessd.Observance.ServiceAttendant do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Observance.Person
  alias Blessd.Observance.Service
  alias Blessd.Observance.ServiceAttendant.Validations

  schema "service_attendants" do
    belongs_to(:service, Service)
    belongs_to(:person, Person)
    field(:is_present, :boolean)

    timestamps()
  end

  @doc false
  def insert_changeset(attendant, attrs) do
    attendant
    |> cast(attrs, [:service_id, :person_id, :is_present])
    |> Validations.basic()
  end

  def update_changeset(attendant, attrs) do
    attendant
    |> cast(attrs, [:is_present])
    |> Validations.basic()
  end
end
