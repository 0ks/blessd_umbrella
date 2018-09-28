defmodule Blessd.Observance do
  @moduledoc """
  The Observance context.
  """

  import Ecto.Query

  alias Blessd.Repo
  alias Blessd.Observance.Person
  alias Blessd.Observance.Service
  alias Blessd.Observance.ServiceAttendant
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
    Service
    |> Repo.get!(id)
    |> Repo.preload(attendants: [:person])
  end

  @doc """
  Creates a service.

  ## Examples

      iex> create_service(%{field: value})
      {:ok, %Service{}}

      iex> create_service(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service(attrs, attendant_ids \\ []) do
    # TODO - decide what to do on attendants insertion errors, or document
    # it if we are not doing anything
    Multi.new()
    |> Multi.insert(:service, Service.changeset(%Service{}, attrs))
    |> Multi.run(:attendants, fn %{service: service} ->
      create_attendants(service, attendant_ids)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, map} ->
        {:ok, map}

      {:error, :service, changeset, _} ->
        {:error, %{service: changeset, attendants: list_attendants(attendant_ids)}}
    end
  end

  @doc """
  Updates a service.

  ## Examples

      iex> update_service(service, %{field: new_value})
      {:ok, %Service{}}

      iex> update_service(service, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_service(%Service{} = service, attrs, attendant_ids \\ []) do
    # TODO - decide what to do on attendants insertion errors, or document
    # it if we are not doing anything
    Multi.new()
    |> Multi.update(:service, Service.changeset(service, attrs))
    |> Multi.run(:attendants, fn %{service: service} ->
      update_attendants(service, attendant_ids)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, map} ->
        {:ok, map}

      {:error, :service, changeset, _} ->
        {:error, %{service: changeset, attendants: list_attendants(attendant_ids)}}
    end
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

  @doc """
  Returns the list of attendants for the given service or list of people attending to it.

  ## Examples

      iex> list_attendants(service)
      [%ServiceAttendant{}, ...]

  """
  def list_attendants(service_or_people_ids \\ [])

  def list_attendants(%Service{attendants: attendants}), do: attendants

  def list_attendants(people_ids) when is_list(people_ids) do
    Person
    |> Repo.all()
    |> Enum.map(fn person ->
      %ServiceAttendant{
        person: person,
        person_id: person.id,
        is_present: person.id in people_ids
      }
    end)
  end

  def create_attendants(%Service{} = service, attendant_ids) do
    Person
    |> select([p], p.id)
    |> Repo.all()
    |> Enum.reduce(Multi.new(), fn person_id, multi ->
      Multi.insert(
        multi,
        :"attendant#{person_id}",
        ServiceAttendant.changeset(%ServiceAttendant{}, %{
          service_id: service.id,
          person_id: person_id,
          is_present: person_id in attendant_ids
        })
      )
    end)
    |> Repo.transaction()
    |> case do
      {:ok, map} ->
        {:ok, Map.values(map)}

      {:error, _, _, _} ->
        {:error, list_attendants(attendant_ids)}
    end
  end

  def update_attendants(%Service{} = service, attendant_ids) do
    service.attendants
    |> Enum.reduce(Multi.new(), fn attendant, multi ->
      Multi.update(
        multi,
        :"attendant#{attendant.person_id}",
        ServiceAttendant.changeset(attendant, %{
          is_present: attendant.person_id in attendant_ids
        })
      )
    end)
    |> Repo.transaction()
    |> case do
      {:ok, map} ->
        {:ok, Map.values(map)}

      {:error, _, _, _} ->
        {:error, list_attendants(attendant_ids)}
    end
  end
end
