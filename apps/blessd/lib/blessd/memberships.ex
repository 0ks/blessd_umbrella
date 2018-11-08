defmodule Blessd.Memberships do
  @moduledoc """
  The Memberships context.
  """

  alias Blessd.Auth
  alias Blessd.Memberships.Person
  alias Blessd.Repo
  alias Ecto.Multi

  @doc """
  Returns the list of people.
  """
  def list_people(current_user) do
    Person
    |> Auth.check!(current_user)
    |> Person.order()
    |> Repo.all()
  end

  @doc """
  Gets a single person.

  Raises `Ecto.NoResultsError` if the Person does not exist.
  """
  def get_person!(id, current_user) do
    Person
    |> Auth.check!(current_user)
    |> Repo.get!(id)
  end

  @doc """
  Creates a person.
  """
  def create_person(attrs, current_user) do
    current_user
    |> new_person()
    |> Person.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Imports a list of people from a file.
  """
  def import_people(stream, current_user) do
    stream
    |> CSV.decode!(headers: true)
    |> create_people(current_user)
    |> case do
      {:ok, people} -> {:ok, people}
      {:error, index, changeset} -> {:error, index + 2, changeset}
    end
  end

  @doc """
  Creates people in batches.
  """
  def create_people(enum, current_user) do
    enum
    |> Stream.with_index()
    |> Enum.reduce(Multi.new(), fn {row, index}, multi ->
      changeset =
        current_user
        |> new_person()
        |> Person.changeset(row)

      Multi.insert(multi, index, changeset)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, map} -> {:ok, Map.values(map)}
      {:error, index, changeset, _} -> {:error, index, changeset}
    end
  end

  @doc """
  Updates a person.
  """
  def update_person(%Person{} = person, attrs, current_user) do
    person
    |> Auth.check!(current_user)
    |> Person.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Person.
  """
  def delete_person(%Person{} = person, current_user) do
    person
    |> Auth.check!(current_user)
    |> Repo.delete()
  end

  @doc """
  Builds a person to insert.
  """
  def new_person(current_user) do
    Auth.check!(%Person{church_id: current_user.church.id}, current_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person changes.
  """
  def change_person(%Person{} = person, current_user) do
    person
    |> Auth.check!(current_user)
    |> Person.changeset(%{})
  end
end
