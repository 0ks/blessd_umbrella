defmodule Blessd.Custom.Fields do
  @moduledoc false

  alias Blessd.Custom.Fields.Field
  alias Blessd.Repo
  alias Blessd.Shared
  alias Ecto.Multi

  import Ecto.Query

  @doc false
  def list(resource, current_user) do
    with {:ok, query} <- Shared.authorize(Field, current_user) do
      query
      |> order()
      |> by_resource(resource)
      |> Repo.list()
    end
  end

  defp by_resource(query, resource), do: where(query, [f], f.resource == ^resource)

  defp order(query), do: order_by(query, [f], [f.position, f.inserted_at])

  @doc false
  def find(id, current_user) do
    with {:ok, query} <- Shared.authorize(Field, current_user) do
      Repo.find(query, id)
    end
  end

  @doc false
  def new_changeset(resource, current_user) do
    with {:ok, field} <- current_user |> build(resource) |> Shared.authorize(current_user) do
      {:ok, Field.changeset(field, %{})}
    end
  end

  @doc false
  def create(resource, attrs, current_user) do
    with {:ok, field} <- current_user |> build(resource) |> Shared.authorize(current_user) do
      field
      |> Field.changeset(attrs)
      |> Repo.insert()
    end
  end

  @doc false
  def edit_changeset(id, current_user) do
    with {:ok, field} <- find(id, current_user),
         {:ok, field} <- Shared.authorize(field, current_user) do
      {:ok, Field.changeset(field, %{})}
    end
  end

  @doc false
  def update(id, attrs, current_user) do
    with {:ok, field} <- find(id, current_user),
         {:ok, field} <- Shared.authorize(field, current_user) do
      field
      |> Field.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc false
  def reorder(resource, ids, current_user) do
    with {:ok, fields} <- list(resource, current_user),
         :ok <- validate_reorder(ids, fields) do
      ids
      |> Stream.map(fn id ->
        Enum.find(fields, &(&1.id == id))
      end)
      |> Stream.with_index()
      |> Stream.map(fn {field, index} ->
        Field.reorder_changeset(field, %{position: index})
      end)
      |> Enum.reduce(Multi.new(), fn changeset, multi ->
        Multi.update(multi, :"field#{changeset.data.id}", changeset)
      end)
      |> Repo.transaction()
      |> case do
        {:ok, result} ->
          fields =
            result
            |> Map.values()
            |> Enum.sort_by(& &1.position)

          {:ok, fields}

        {:error, _operation, _changeset, _changes} ->
          {:error, :invalid_field_position}
      end
    end
  end

  defp validate_reorder(ids, fields) do
    if Enum.map(fields, & &1.id) -- ids == [] do
      :ok
    else
      {:error, :invalid_field_list}
    end
  end

  @doc false
  def delete(id, current_user) do
    with {:ok, field} <- find(id, current_user),
         {:ok, field} <- Shared.authorize(field, current_user) do
      Repo.delete(field)
    end
  end

  defp build(current_user, resource) do
    %Field{church_id: current_user.church_id, resource: resource}
  end
end
