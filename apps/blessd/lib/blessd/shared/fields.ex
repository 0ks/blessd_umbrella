defmodule Blessd.Shared.Fields do
  @moduledoc false

  import Ecto.Query

  alias Blessd.Repo
  alias Blessd.Shared
  alias Blessd.Shared.Fields.Field

  @doc false
  def all(resource, church_id) do
    Field
    |> where([f], f.church_id == ^church_id)
    |> order()
    |> by_resource(resource)
    |> Repo.all()
  end

  @doc false
  def list(resource, current_user) do
    with {:ok, query} <- Shared.authorize(Field, current_user) do
      query
      |> order()
      |> by_resource(resource)
      |> Repo.list()
    end
  end

  @doc false
  def by_resource(query, resource), do: where(query, [f], f.resource == ^resource)

  @doc false
  def order(query), do: order_by(query, [f], [f.position, f.inserted_at, f.id])

  @doc false
  def name(%{id: id}), do: :"field#{id}"
end
