defmodule Blessd.Auth.Churches do
  @moduledoc false

  import Ecto.Query

  alias Blessd.Auth.Churches.Church
  alias Blessd.Repo
  alias Ecto.Query
  alias Ecto.Queryable

  @doc false
  def find(slug) when is_binary(slug) do
    case Integer.parse(slug) do
      {id, _} -> find(id)
      :error -> Repo.find_by(Church, slug: slug)
    end
  end

  def find(id) when is_integer(id) do
    Repo.find(Church, id)
  end

  @doc false
  def check(module, %Church{} = church) when is_atom(module) do
    module
    |> Queryable.to_query()
    |> check(church)
  end

  def check(%Query{} = query, %Church{id: church_id}) do
    {:ok, where(query, [t], t.church_id == ^church_id)}
  end

  def check(%{church_id: id} = resource, %Church{id: id}), do: {:ok, resource}
  def check(_, %Church{}), do: {:error, :unauthorized}
end
