defmodule Blessd.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query

  alias Blessd.Accounts.Church
  alias Blessd.Accounts.User
  alias Blessd.Auth
  alias Blessd.Repo
  alias Ecto.Query
  alias Ecto.Queryable

  @doc """
  Gets a single church by id or identifier.
  """
  def find_church(identifier, current_user) when is_binary(identifier) do
    case Integer.parse(identifier) do
      {id, _} ->
        find_church(id, current_user)

      :error ->
        with {:ok, query} <- authorize(Church, :find, current_user) do
          Repo.find_by(query, identifier: identifier)
        end
    end
  end

  def find_church(id, current_user) when is_integer(id) do
    with {:ok, query} <- authorize(Church, :find, current_user), do: Repo.find(query, id)
  end

  @doc """
  Updates a church.
  """
  def update_church(%Church{} = church, attrs, current_user) do
    with {:ok, church} <- authorize(church, :update, current_user) do
      church
      |> Church.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a Church.
  """
  def delete_church(%Church{} = church, current_user) do
    with {:ok, church} <- authorize(church, :delete, current_user) do
      Repo.delete(church)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking church changes.
  """
  def change_church(%Church{} = church, current_user) do
    with {:ok, church} <- authorize(church, :change, current_user) do
      {:ok, Church.changeset(church, %{})}
    end
  end

  @doc """
  Returns the list of users.
  """
  def list_users(current_user) do
    with {:ok, query} <- authorize(User, :list, current_user) do
      query
      |> User.order()
      |> Repo.list()
    end
  end

  @doc """
  Gets a single user.
  """
  def find_user(id, current_user) do
    with {:ok, query} <- authorize(User, :find, current_user), do: Repo.find(query, id)
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs, current_user) do
    with {:ok, user} <- authorize(user, :update, current_user) do
      user
      |> User.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a User.
  """
  def delete_user(%User{} = user, current_user) do
    with {:ok, user} <- authorize(user, :delete, current_user), do: Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, current_user) do
    with {:ok, user} <- authorize(user, :change, current_user) do
      {:ok, User.changeset(user, %{})}
    end
  end

  @doc """
  Authorizes the given resource. If authorized, it returns
  `{:ok, resource}`, otherwise, returns `{:error, reason}`,
  """
  def authorize(Church, action, current_user) do
    Church
    |> Queryable.to_query()
    |> authorize(action, current_user)
  end

  def authorize(%Query{from: %{source: {_, Church}}} = query, _, %{church_id: church_id}) do
    {:ok, where(query, [t], t.id == ^church_id)}
  end

  def authorize(%Church{id: id} = church, _, %{church_id: id}), do: {:ok, church}

  def authorize(User, action, current_user) do
    User
    |> Queryable.to_query()
    |> authorize(action, current_user)
  end

  def authorize(%Query{from: %{source: {_, User}}} = query, :find, %{id: id}) do
    {:ok, where(query, [t], t.id == ^id)}
  end

  def authorize(%Query{from: %{source: {_, User}}} = query, _, current_user) do
    Auth.check(query, current_user)
  end

  def authorize(%User{id: id} = user, action, %{id: id}) when action in [:update, :change] do
    {:ok, user}
  end

  def authorize(%User{} = user, :delete, current_user) do
    Auth.check(user, current_user)
  end

  def authorize(_resource, _action, _current_user), do: {:error, :unauthorized}

  @doc """
  Returns `true` if the given current_user is authorized
  to do the given action to the resource.
  """
  def authorized?(resource, action, current_user) do
    case authorize(resource, action, current_user) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
