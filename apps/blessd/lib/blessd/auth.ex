defmodule Blessd.Auth do
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Auth.User
  alias Blessd.Repo
  alias Ecto.Query
  alias Ecto.Queryable

  @doc """
  Gets a single church by id or identifier.

  Raises `Ecto.NoResultsError` if the Church does not exist.
  """
  def find_church(identifier) when is_binary(identifier) do
    case Integer.parse(identifier) do
      {id, _} -> find_church(id)
      :error -> Repo.find_by(Church, identifier: identifier)
    end
  end

  def find_church(id) when is_integer(id) do
    Repo.find(Church, id)
  end

  @doc """
  Gets a single user by id and church.

  Raises `Ecto.NoResultsError` if the Church does not exist.
  """
  def find_user(id, church_id) when is_binary(church_id) or is_integer(church_id) do
    with {:ok, church} <- find_church(church_id), do: find_user(id, church)
  end

  def find_user(id, %Church{} = church) do
    with {:ok, query} <- check_church(User, church),
         {:ok, user} <- Repo.find(query, id) do
      {:ok, Map.put(user, :church, church)}
    end
  end

  @doc """
  Check if the given module, query or resource is from the
  given user and it's church.
  """
  def check(_, %User{confirmed_at: nil}), do: {:error, :unconfirmed}
  def check(checkable, %User{church: church}), do: check_church(checkable, church)

  def check_church(module, %Church{} = church) when is_atom(module) do
    module
    |> Queryable.to_query()
    |> check_church(church)
  end

  def check_church(%Query{} = query, %Church{id: church_id}) do
    {:ok, where(query, [t], t.church_id == ^church_id)}
  end

  def check_church(%{church_id: id} = resource, %Church{id: id}), do: {:ok, resource}
  def check_church(_, %Church{}), do: {:error, :unauthorized}
end
