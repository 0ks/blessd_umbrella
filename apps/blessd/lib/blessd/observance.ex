defmodule Blessd.Observance do
  @moduledoc """
  The Observance context.
  """

  import Ecto.Query

  alias Blessd.Repo
  alias Blessd.Observance.Person
  alias Blessd.Observance.Service
  alias Blessd.Observance.ServiceAttendant
  alias Blessd.Observance.ServiceAttendant.Queries, as: ServiceAttendantQueries
  alias Ecto.Multi

  @doc """
  Returns the list of services.
  """
  def list_services do
    Service
    |> order_by([s], desc: s.date)
    |> Repo.all()
  end

  @doc """
  Gets a single service.

  Raises `Ecto.NoResultsError` if the Service does not exist.
  """
  def get_service!(id) do
    attendants_query =
      ServiceAttendant
      |> ServiceAttendantQueries.preload()
      |> ServiceAttendantQueries.order_preloaded()

    Service
    |> preload(attendants: ^attendants_query)
    |> Repo.get!(id)
  end

  @doc """
  Creates a service.
  """
  def create_service(attrs) do
    %Service{}
    |> Service.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a service.
  """
  def update_service(%Service{} = service, attrs) do
    service
    |> Service.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Service.
  """
  def delete_service(%Service{} = service) do
    Repo.delete(service)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service changes.
  """
  def change_service(%Service{} = service) do
    Service.changeset(service, %{})
  end

  @doc """
  Returns the list of service attendants.

  If the service has no attendant, it calls `create_attendants/1`
  for the given service.
  """
  def list_attendants(%Service{attendants: []} = service) do
    case create_attendants(service) do
      {:ok, _attendants} ->
        ServiceAttendant
        |> ServiceAttendantQueries.by_service(service.id)
        |> ServiceAttendantQueries.preload()
        |> ServiceAttendantQueries.order_preloaded()
        |> Repo.all()

      {:error, _changeset} ->
        raise "Error creating first attendants"
    end
  end

  def list_attendants(%Service{attendants: attendants}) do
    attendants
  end

  @doc """
  Search for attendants.
  """
  def search_attendants(service_id, query) do
    ServiceAttendant
    |> ServiceAttendantQueries.by_service(service_id)
    |> ServiceAttendantQueries.preload()
    |> ServiceAttendantQueries.search(query)
    |> ServiceAttendantQueries.order_preloaded()
    |> Repo.all()
  end

  @doc """
  Gets a single attendant.

  Raises `Ecto.NoResultsError` if the Service does not exist.
  """
  def get_attendant!(attendant_id), do: Repo.get!(ServiceAttendant, attendant_id)

  @doc """
  Updates an attendant.
  """
  def update_attendant(%ServiceAttendant{} = attendant, attrs) do
    attendant
    |> ServiceAttendant.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Create initial attendants for the given service.
  """
  def create_attendants(%Service{id: service_id}) do
    Person
    |> select([p], p.id)
    |> Repo.all()
    |> Enum.reduce(Multi.new(), fn person_id, multi ->
      Multi.insert(
        multi,
        :"attendant#{person_id}",
        ServiceAttendant.insert_changeset(%ServiceAttendant{}, %{
          service_id: service_id,
          person_id: person_id,
          is_present: false
        })
      )
    end)
    |> Repo.transaction()
    |> case do
      {:ok, map} -> {:ok, Map.values(map)}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end
end
