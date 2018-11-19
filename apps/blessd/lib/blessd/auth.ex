defmodule Blessd.Auth do
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Auth.User
  alias Blessd.NotAuthorizedError
  alias Blessd.Repo
  alias Ecto.Query
  alias Ecto.Queryable

  @doc """
  Gets a single church by id or identifier.

  Raises `Ecto.NoResultsError` if the Church does not exist.
  """
  def get_church!(identifier) when is_binary(identifier) do
    case Integer.parse(identifier) do
      {id, _} -> get_church!(id)
      :error -> Repo.get_by!(Church, identifier: identifier)
    end
  end

  def get_church!(id) when is_integer(id) do
    Repo.get!(Church, id)
  end

  @doc """
  Gets a single user by id and church.

  Raises `Ecto.NoResultsError` if the Church does not exist.
  """
  def get_user!(id, church_id) when is_binary(church_id) or is_integer(church_id) do
    get_user!(id, get_church!(church_id))
  end

  def get_user!(id, %Church{} = church) do
    User
    |> check_church!(church)
    |> Repo.get!(id)
    |> Map.put(:church, church)
  end

  @church_modules [Blessd.Accounts.Church]

  @doc """
  Check if the given module, query or resource is from the
  given user and it's church.
  """
  def check!(checkable, %User{church: church}), do: check_church!(checkable, church)

  defp check_church!(module, %Church{} = church) when is_atom(module) do
    module
    |> Queryable.to_query()
    |> check_church!(church)
  end

  defp check_church!(%Query{from: %{source: {_, m}}} = q, %Church{id: id})
       when m in @church_modules do
    where(q, [t], t.id == ^id)
  end

  defp check_church!(%Query{} = query, %Church{id: church_id}) do
    where(query, [t], t.church_id == ^church_id)
  end

  defp check_church!(%m{id: id} = resource, %Church{id: id}) when m in @church_modules do
    resource
  end

  defp check_church!(%{church_id: id} = resource, %Church{id: id}), do: resource
  defp check_church!(_, %Church{}), do: raise(NotAuthorizedError)
end
