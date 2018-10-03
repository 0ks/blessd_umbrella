defmodule Blessd.Observance do
  @moduledoc """
  The Observance context.
  """

  import Ecto.Query

  alias Blessd.Repo
  alias Blessd.Observance.Person
  alias Blessd.Observance.Service
  alias Blessd.Observance.ServiceAttendant
  alias Blessd.ServiceAttendant.Queries, as: ServiceAttendantQueries
  alias Ecto.Multi

  @doc """
  Returns the list of services.

  ## Examples

      iex> list_services()
      [%Service{}, ...]

  """
  def list_services do
    Repo.all(Service)
  end

  @doc """
  Gets a single service.

  Raises `Ecto.NoResultsError` if the Service does not exist.

  ## Examples

      iex> get_service!(123)
      %Service{}

      iex> get_service!(456)
      ** (Ecto.NoResultsError)

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

  This function also create a ServiceAttendant for each Person
  on the database in the moment of its creation.

  ## Examples

      iex> create_service(%{field: value})
      {:ok, %Service{}}

      iex> create_service(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service(attrs) do
    %Service{}
    |> Service.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a service.

  ## Examples

      iex> update_service(service, %{field: new_value})
      {:ok, %Service{}}

      iex> update_service(service, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_service(%Service{} = service, attrs) do
    service
    |> Service.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Service.

  ## Examples

      iex> delete_service(service)
      {:ok, %Service{}}

      iex> delete_service(service)
      {:error, %Ecto.Changeset{}}

  """
  def delete_service(%Service{} = service) do
    Repo.delete(service)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service changes.

  ## Examples

      iex> change_service(service)
      %Ecto.Changeset{source: %Service{}}

  """
  def change_service(%Service{} = service) do
    Service.changeset(service, %{})
  end

  def list_attendants(%Service{attendants: []} = service) do
    service
    |> create_attendants()
    |> case do
      {:ok, _attendants} ->
        ServiceAttendant
        |> ServiceAttendantQueries.by_service(service.id)
        |> ServiceAttendantQueries.preload()
        |> ServiceAttendantQueries.order_preloaded()
        |> Repo.all()

      {:error, changeset} ->
        raise "Error creating first attendants"
    end
  end

  def list_attendants(%Service{attendants: attendants}) do
    attendants
  end

  def search_attendants(service_id, query) do
    ServiceAttendant
    |> ServiceAttendantQueries.by_service(service_id)
    |> ServiceAttendantQueries.preload()
    |> ServiceAttendantQueries.search(query)
    |> ServiceAttendantQueries.order_preloaded()
    |> Repo.all()
  end

  def get_attendant!(attendant_id), do: Repo.get!(ServiceAttendant, attendant_id)

  def update_attendant(%ServiceAttendant{} = attendant, attrs) do
    attendant
    |> ServiceAttendant.update_changeset(attrs)
    |> Repo.update()
  end

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
