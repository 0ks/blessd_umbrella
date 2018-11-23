defmodule Blessd.Memberships do
  @moduledoc """
  The Memberships context.
  """

  alias Blessd.Shared
  alias Blessd.Memberships.Person
  alias Blessd.Repo
  alias Ecto.Multi

  @doc """
  Returns the list of people.
  """
  def list_people(current_user) do
    with {:ok, query} <- Shared.authorize(Person, current_user) do
      query
      |> Person.order()
      |> Repo.list()
    end
  end

  @doc """
  Gets a single person.
  """
  def find_person(id, current_user) do
    with {:ok, query} <- Shared.authorize(Person, current_user), do: Repo.find(query, id)
  end

  @doc """
  Creates a person.
  """
  def create_person(attrs, current_user) do
    with {:ok, person} <- new_person(current_user) do
      person
      |> Person.changeset(attrs)
      |> Repo.insert()
    end
  end

  @doc """
  Imports a list of people from a file.
  """
  def import_people(stream, current_user) do
    with enum = CSV.decode!(stream, headers: true),
         {:ok, people} <- create_people(enum, current_user) do
      {:ok, people}
    else
      {:error, index, changeset} -> {:error, index + 2, changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Creates people in batches.
  """
  def create_people(enum, current_user) do
    enum
    |> Stream.with_index()
    |> Enum.reduce(Multi.new(), fn {row, index}, multi ->
      with {:ok, person} <- new_person(current_user),
           changeset = Person.changeset(person, row) do
        Multi.insert(multi, index, changeset)
      else
        {:error, reason} -> Multi.run(multi, index, fn _, _ -> {:error, reason} end)
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, map} -> {:ok, Map.values(map)}
      {:error, index, %Ecto.Changeset{} = changeset, _} -> {:error, index, changeset}
      {:error, _, reason, _} -> {:error, reason}
    end
  end

  @doc """
  Updates a person.
  """
  def update_person(%Person{} = person, attrs, current_user) do
    with {:ok, person} <- Shared.authorize(person, current_user) do
      person
      |> Person.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a Person.
  """
  def delete_person(%Person{} = person, current_user) do
    with {:ok, person} <- Shared.authorize(person, current_user), do: Repo.delete(person)
  end

  @doc """
  Builds a person to insert.
  """
  def new_person(current_user) do
    Shared.authorize(%Person{church_id: current_user.church.id}, current_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person changes.
  """
  def change_person(%Person{} = person, current_user) do
    with {:ok, person} <- Shared.authorize(person, current_user) do
      {:ok, Person.changeset(person, %{})}
    end
  end
end
