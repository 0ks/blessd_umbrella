defmodule Blessd.Custom.Fields do
  @moduledoc false

  alias Blessd.Custom.Fields.Field
  alias Blessd.Repo
  alias Blessd.Shared

  @doc false
  def list(current_user) do
    with {:ok, query} <- Shared.authorize(Field, current_user) do
      Repo.list(query)
    end
  end

  @doc
  def find(id, current_user) do
    with {:ok, query} <- Shared.authorize(Field, current_user) do
      Repo.find(query, id)
    end
  end

  @doc false
  def new_changeset(current_user) do
    with {:ok, field} <- current_user |> build() |> Shared.authorize(current_user) do
      {:ok, Field.new_changeset(field, current_user)}
    end
  end

  @doc false
  def create(attrs, current_user) do
    with {:ok, field} <- current_user |> build() |> Shared.authorize(current_user) do
      field
      |> Field.new_changeset(current_user)
      |> Repo.insert()
    end
  end

  @doc false
  def edit_changeset(%Field{} = field, current_user) do
    with {:ok, field} <- Shared.authorize(field, current_user) do
      {:ok, Field.edit_changeset(field, current_user)}
    end
  end

  def edit_changeset(id, current_user) do
    with {:ok, field} <- find(id, current_user) do
      edit_changeset(field, current_user)
    end
  end

  @doc false
  def update(%Field{} = field, attrs, current_user) do
    with {:ok, field} <- Shared.authorize(field, current_user) do
      field
      |> Field.edit_changeset(current_user)
      |> Repo.update()
    end
  end

  def update(id, attrs, current_user) do
    with {:ok, field} <- find(id, current_user) do
      update(field, attrs, current_user)
    end
  end

  @doc false
  def delete(%Field{} = field, current_user) do
    with {:ok, field} <- Shared.authorize(field, current_user) do
      Repo.delete(field)
    end
  end

  def delete(id, current_user) do
    with {:ok, field} <- find(id, current_user) do
      delete(field, current_user)
    end
  end

  defp build(current_user), do: %Field{church_id: current_user.church_id}
end

