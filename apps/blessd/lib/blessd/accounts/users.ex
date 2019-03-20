defmodule Blessd.Accounts.Users do
  @moduledoc """
  Secondary context for users
  """

  import Ecto.Query

  alias Blessd.Accounts.Users.User
  alias Blessd.Shared
  alias Blessd.Repo
  alias Ecto.Query
  alias Ecto.Queryable

  @doc false
  def list(current_user) do
    with {:ok, query} <- authorize(User, :list, current_user) do
      query
      |> User.order()
      |> preload(:church)
      |> Repo.list()
    end
  end

  @doc false
  def find(id, current_user) do
    with {:ok, query} <- authorize(User, :find, current_user) do
      query
      |> preload(:church)
      |> Repo.find(id)
    end
  end

  @doc false
  def edit_changeset(id, current_user) do
    with {:ok, user} <- find(id, current_user),
         {:ok, user} <- authorize(user, :edit, current_user) do
      {:ok, User.changeset(user, %{})}
    end
  end

  @doc false
  def update(id, attrs, current_user) do
    with {:ok, user} <- find(id, current_user),
         {:ok, user} <- authorize(user, :update, current_user) do
      user
      |> User.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc false
  def delete(id, current_user) do
    with {:ok, user} <- find(id, current_user),
         {:ok, user} <- authorize(user, :delete, current_user) do
      Repo.delete(user)
    end
  end

  @doc false
  def authorize(User, action, current_user) do
    User
    |> Queryable.to_query()
    |> authorize(action, current_user)
  end

  def authorize(%Query{from: %{source: {_, User}}} = query, action, %{id: id})
      when action in [:edit, :update] do
    {:ok, where(query, [t], t.id == ^id)}
  end

  def authorize(%Query{from: %{source: {_, User}}} = query, _, current_user) do
    Shared.authorize(query, current_user)
  end

  def authorize(%User{id: id} = user, action, %{id: id}) when action in [:update, :edit] do
    {:ok, user}
  end

  def authorize(%User{} = user, :delete, current_user) do
    Shared.authorize(user, current_user)
  end

  def authorize(_resource, _action, _current_user), do: {:error, :unauthorized}

  @doc false
  def authorized?(resource, action, current_user) do
    case authorize(resource, action, current_user) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
