defmodule Blessd.Observance do
  @moduledoc """
  The Observance context.
  """

  alias Blessd.Auth
  alias Blessd.Observance.Person
  alias Blessd.Observance.Service
  alias Blessd.Observance.Attendant
  alias Blessd.Repo

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
  Returns the list of people with their attendants preloaded.
  """
  def list_people(current_user) do
    Person
    |> Auth.check!(current_user)
    |> Person.preload()
    |> Person.order()
    |> Repo.all()
  end

  @doc """
  Search for people and preload their attendants.
  """
  def search_people(query, current_user) do
    Person
    |> Auth.check!(current_user)
    |> Person.preload()
    |> Person.order()
    |> Person.search(query)
    |> Repo.all()
  end

  @doc """
  Creates an attendant if it does not exists and removes it if it exists.
  """
  def toggle_attendant(person_id, service_id, current_user) do
    case Repo.get_by(Attendant, person_id: person_id, service_id: service_id) do
      nil ->
        current_user
        |> new_attendant()
        |> Attendant.changeset(%{person_id: person_id, service_id: service_id})
        |> Repo.insert()

      %Attendant{} = attendant ->
        attendant
        |> Auth.check!(current_user)
        |> Repo.delete()
    end
  end

  @doc """
  Builds an attendant to insert.
  """
  def new_attendant(current_user) do
    Auth.check!(%Attendant{church_id: current_user.church.id}, current_user)
  end
end
