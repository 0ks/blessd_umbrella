defmodule Blessd.Shared.Churches do
  @moduledoc false

  import Ecto.Query

  alias Blessd.Shared.Churches.Church
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
  def authorize(module, %Church{} = church) when is_atom(module) do
    module
    |> Queryable.to_query()
    |> authorize(church)
  end

  def authorize(%Query{} = query, %Church{id: church_id}) do
    {:ok, where(query, [t], t.church_id == ^church_id)}
  end

  def authorize(%{church_id: id} = resource, %Church{id: id}), do: {:ok, resource}
  def authorize(_, %Church{}), do: {:error, :unauthorized}
end
