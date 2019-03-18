defmodule Blessd.Accounts.Churches do
  @moduledoc """
  Secondary context for churches
  """

  import Ecto.Query

  alias Blessd.Accounts.Churches.Church
  alias Blessd.Repo
  alias Ecto.Query
  alias Ecto.Queryable

  @doc false
  def find(slug, current_user) when is_binary(slug) do
    case Integer.parse(slug) do
      {id, _} ->
        find(id, current_user)

      :error ->
        with {:ok, query} <- authorize(Church, :find, current_user) do
          Repo.find_by(query, slug: slug)
        end
    end
  end

  def find(id, current_user) when is_integer(id) do
    with {:ok, query} <- authorize(Church, :find, current_user), do: Repo.find(query, id)
  end

  @doc false
  def edit_changeset(id, current_user) do
    with {:ok, church} <- find(id, current_user),
         {:ok, church} <- authorize(church, :edit, current_user) do
      {:ok, Church.changeset(church, %{})}
    end
  end

  @doc false
  def update(id, attrs, current_user) do
    with {:ok, church} <- find(id, current_user),
         {:ok, church} <- authorize(church, :update, current_user) do
      church
      |> Church.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc false
  def delete(id, current_user) do
    with {:ok, church} <- find(id, current_user),
         {:ok, church} <- authorize(church, :delete, current_user) do
      Repo.delete(church)
    end
  end

  @doc false
  def authorize(Church, action, current_user) do
    Church
    |> Queryable.to_query()
    |> authorize(action, current_user)
  end

  def authorize(%Query{from: %{source: {_, Church}}} = query, _, %{church_id: church_id}) do
    {:ok, where(query, [t], t.id == ^church_id)}
  end

  def authorize(%Church{id: id} = church, _, %{church_id: id}), do: {:ok, church}
end
