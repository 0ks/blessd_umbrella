defmodule Blessd.Auth do
  import Ecto.Query

  alias Blessd.Auth.Church
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

  def check!(module, church) when is_atom(module) do
    module
    |> Queryable.to_query()
    |> check!(church)
  end

  def check!(%Query{} = query, %Church{id: church_id}) do
    where(query, [t], t.church_id == ^church_id)
  end

  def check!(%{church_id: church_id} = resource, %Church{id: church_id}), do: resource
  def check!(_, %Church{}), do: raise(NotAuthorizedError)
end
