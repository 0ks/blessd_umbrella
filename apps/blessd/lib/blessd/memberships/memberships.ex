defmodule Blessd.Memberships do
  @moduledoc """
  The Memberships context.
  """

  alias Blessd.Repo
  alias Blessd.Memberships.Person
  alias Ecto.Multi

  @doc """
  Returns the list of people.

  ## Examples

      iex> list_people()
      [%Person{}, ...]

  """
  def list_people do
    Repo.all(Person)
  end

  @doc """
  Gets a single person.

  Raises `Ecto.NoResultsError` if the Person does not exist.

  ## Examples

      iex> get_person!(123)
      %Person{}

      iex> get_person!(456)
      ** (Ecto.NoResultsError)

  """
  def get_person!(id), do: Repo.get!(Person, id)

  @doc """
  Creates a person.

  ## Examples

      iex> create_person(%{field: value})
      {:ok, %Person{}}

      iex> create_person(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_person(attrs \\ %{}) do
    %Person{}
    |> Person.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Imports a list of people from a file.
  """
  def import_people(stream) do
    stream
    |> CSV.decode!(headers: true)
    |> create_people()
    |> case do
      {:ok, people} -> {:ok, people}
      {:error, index, changeset} -> {:error, index + 2, changeset}
    end
  end

  @doc """
  Creates people in batches.
  """
  def create_people(enum) do
    enum
    |> Stream.with_index()
    |> Enum.reduce(Multi.new(), fn {row, index}, multi ->
      Multi.insert(multi, index, Person.changeset(%Person{}, row))
    end)
    |> Repo.transaction()
    |> case do
      {:ok, map} -> {:ok, Map.values(map)}
      {:error, index, changeset, _} -> {:error, index, changeset}
    end
  end

  @doc """
  Updates a person.

  ## Examples

      iex> update_person(person, %{field: new_value})
      {:ok, %Person{}}

      iex> update_person(person, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_person(%Person{} = person, attrs) do
    person
    |> Person.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Person.

  ## Examples

      iex> delete_person(person)
      {:ok, %Person{}}

      iex> delete_person(person)
      {:error, %Ecto.Changeset{}}

  """
  def delete_person(%Person{} = person) do
    Repo.delete(person)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person changes.

  ## Examples

      iex> change_person(person)
      %Ecto.Changeset{source: %Person{}}

  """
  def change_person(%Person{} = person) do
    Person.changeset(person, %{})
  end
end
