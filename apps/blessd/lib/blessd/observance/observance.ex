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
    # TODO - a better way to guarantee the consistence of
    # attendants creation would be on db-level
    Multi.new()
    |> Multi.insert(:service, Service.changeset(%Service{}, attrs))
    |> Multi.run(:attendants, fn %{service: service} ->
      create_attendants(service)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{service: service}} -> {:ok, service}
      {:error, :service, changeset, _} -> {:error, changeset}
    end
  end

  defp create_attendants(%Service{id: service_id}) do
    Person
    |> select([p], p.id)
    |> Repo.all()
    |> Enum.reduce(Multi.new(), fn person_id, multi ->
      Multi.insert(
        multi,
        :"attendant#{person_id}",
        ServiceAttendant.changeset(%ServiceAttendant{}, %{
          service_id: service_id,
          person_id: person_id,
          is_present: false
        })
      )
    end)
    |> Repo.transaction()
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
end
