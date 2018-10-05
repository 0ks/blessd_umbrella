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
  def list_people(church) do
    Person
    |> Auth.check!(church)
    |> Person.order()
    |> Repo.all()
  end

  @doc """
  Gets a single person.

  Raises `Ecto.NoResultsError` if the Person does not exist.
  """
  def get_person!(id, church) do
    Person
    |> Auth.check!(church)
    |> Repo.get!(id)
  end

  @doc """
  Creates a person.
  """
  def create_person(attrs, church) do
    church
    |> new_person()
    |> Person.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Imports a list of people from a file.
  """
  def import_people(stream, church) do
    stream
    |> CSV.decode!(headers: true)
    |> create_people(church)
    |> case do
      {:ok, people} -> {:ok, people}
      {:error, index, changeset} -> {:error, index + 2, changeset}
    end
  end

  @doc """
  Creates people in batches.
  """
  def create_people(enum, church) do
    enum
    |> Stream.with_index()
    |> Enum.reduce(Multi.new(), fn {row, index}, multi ->
      changeset =
        church
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
  def update_person(%Person{} = person, attrs, church) do
    person
    |> Auth.check!(church)
    |> Person.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Person.
  """
  def delete_person(%Person{} = person, church) do
    person
    |> Auth.check!(church)
    |> Repo.delete()
  end

  @doc """
  Builds a person to insert.
  """
  def new_person(church) do
    Auth.check!(%Person{church_id: church.id}, church)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person changes.
  """
  def change_person(%Person{} = person, church) do
    person
    |> Auth.check!(church)
    |> Person.changeset(%{})
  end
end
