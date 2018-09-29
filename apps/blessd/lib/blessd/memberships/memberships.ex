defmodule Blessd.Memberships do
  @moduledoc """
  The Memberships context.
  """

  import Ecto.Query

  alias Blessd.Repo
  alias Blessd.Memberships.Person
  alias Blessd.Memberships.Service
  alias Blessd.Memberships.ServiceAttendant
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
    # TODO - a better way to guarantee the consistence of
    # attendants creation would be on db-level
    Multi.new()
    |> Multi.insert(:person, Person.changeset(%Person{}, attrs))
    |> Multi.run(:attendants, fn %{person: person} ->
      create_attendants(person)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{person: person}} -> {:ok, person}
      {:error, :person, changeset, _} -> {:error, changeset}
    end
  end

  defp create_attendants(%Person{id: person_id}) do
    Service
    |> select([s], s.id)
    |> Repo.all()
    |> Enum.reduce(Multi.new(), fn service_id, multi ->
      Multi.insert(
        multi,
        :"attendant#{service_id}",
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
