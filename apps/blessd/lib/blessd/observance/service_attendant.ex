defmodule Blessd.Observance.ServiceAttendant do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Observance.Person
  alias Blessd.Observance.Service

  schema "service_attendants" do
    belongs_to(:church, Church)

    belongs_to(:service, Service)
    belongs_to(:person, Person)

    field(:is_present, :boolean)

    timestamps()
  end

  @doc false
  def insert_changeset(attendant, attrs) do
    attendant
    |> cast(attrs, [:service_id, :person_id, :is_present])
    |> basic_validations()
  end

  def update_changeset(attendant, attrs) do
    attendant
    |> cast(attrs, [:is_present])
    |> basic_validations()
  end

  defp basic_validations(changeset) do
    validate_required(changeset, [:service_id, :person_id, :is_present])
  end

  def order_preloaded(query) do
    order_by(query, [a, p], p.name)
  end

  def preload(query) do
    query
    |> join(:inner, [a], p in assoc(a, :person))
    |> preload([a, p], person: p)
  end

  def by_service(query, %Service{id: service_id}), do: by_service(query, service_id)
  def by_service(query, service_id), do: where(query, [a], a.service_id == ^service_id)

  def search(query, query_str) do
    query_str = "%#{query_str}%"

    where(
      query,
      [a, p],
      fragment("? ilike ?", p.name, ^query_str) or fragment("? ilike ?", p.email, ^query_str)
    )
  end
end
