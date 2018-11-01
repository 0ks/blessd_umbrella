defmodule Blessd.Observance do
  @moduledoc """
  The Observance context.
  """

  alias Blessd.Auth
  alias Blessd.Observance.Person
  alias Blessd.Observance.Service
  alias Blessd.Observance.ServiceAttendant
  alias Blessd.Repo
  alias Ecto.Multi

  @doc """
  Returns the list of services.
  """
  def list_services(current_user) do
    Service
    |> Auth.check!(current_user)
    |> Service.order()
    |> Repo.all()
  end

  @doc """
  Gets a single service.

  Raises `Ecto.NoResultsError` if the Service does not exist.
  """
  def get_service!(id, current_user) do
    Service
    |> Auth.check!(current_user)
    |> Service.order()
    |> Service.preload()
    |> Repo.get!(id)
  end

  @doc """
  Creates a service.
  """
  def create_service(attrs, current_user) do
    current_user
    |> new_service()
    |> Service.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a service.
  """
  def update_service(%Service{} = service, attrs, current_user) do
    service
    |> Auth.check!(current_user)
    |> Service.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Service.
  """
  def delete_service(%Service{} = service, current_user) do
    service
    |> Auth.check!(current_user)
    |> Repo.delete()
  end

  @doc """
  Builds a service to insert.
  """
  def new_service(current_user) do
    Auth.check!(%Service{church_id: current_user.church.id}, current_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service changes.
  """
  def change_service(%Service{} = service, current_user) do
    service
    |> Auth.check!(current_user)
    |> Service.changeset(%{})
  end

  @doc """
  Returns the list of service attendants.

  If the service has no attendant, it calls `create_attendants/1`
  for the given service.
  """
  def list_attendants(%Service{attendants: []} = service, current_user) do
    case create_attendants(service, current_user) do
      {:ok, _attendants} ->
        ServiceAttendant
        |> Auth.check!(current_user)
        |> ServiceAttendant.by_service(service)
        |> ServiceAttendant.preload()
        |> ServiceAttendant.order_preloaded()
        |> Repo.all()

      {:error, _changeset} ->
        raise "Error creating first attendants"
    end
  end

  def list_attendants(%Service{attendants: attendants} = service, current_user) do
    Auth.check!(service, current_user)
    attendants
  end

  @doc """
  Search for attendants.
  """
  def search_attendants(%Service{} = service, query, current_user) do
    ServiceAttendant
    |> Auth.check!(current_user)
    |> ServiceAttendant.by_service(service)
    |> ServiceAttendant.preload()
    |> ServiceAttendant.order_preloaded()
    |> ServiceAttendant.search(query)
    |> Repo.all()
  end

  @doc """
  Gets a single attendant.

  Raises `Ecto.NoResultsError` if the Service does not exist.
  """
  def get_attendant!(attendant_id, current_user) do
    ServiceAttendant
    |> Auth.check!(current_user)
    |> Repo.get!(attendant_id)
  end

  @doc """
  Updates an attendant.
  """
  def update_attendant(%ServiceAttendant{} = attendant, attrs, current_user) do
    attendant
    |> Auth.check!(current_user)
    |> ServiceAttendant.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Builds an attendant to insert.
  """
  def new_attendant(current_user) do
    Auth.check!(%ServiceAttendant{church_id: current_user.church.id}, current_user)
  end

  @doc """
  Create initial attendants for the given service.
  """
  def create_attendants(%Service{id: service_id} = service, current_user) do
    Auth.check!(service, current_user)

    Person
    |> Auth.check!(current_user)
    |> Person.select_ids()
    |> Repo.all()
    |> Enum.reduce(Multi.new(), fn person_id, multi ->
      changeset =
        current_user
        |> new_attendant()
        |> ServiceAttendant.insert_changeset(%{
          service_id: service_id,
          person_id: person_id,
          is_present: false
        })

      Multi.insert(multi, :"attendant#{person_id}", changeset)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, map} -> {:ok, Map.values(map)}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end
end
