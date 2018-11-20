defmodule Blessd.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Blessd.Accounts.Church
  alias Blessd.Accounts.User
  alias Blessd.Auth
  alias Blessd.Repo

  @doc """
  Gets a single church by id or identifier.
  """
  def find_church(identifier, current_user) when is_binary(identifier) do
    case Integer.parse(identifier) do
      {id, _} ->
        find_church(id, current_user)

      :error ->
        with {:ok, query} <- Auth.check(Church, current_user) do
          Repo.find_by(query, identifier: identifier)
        end
    end
  end

  def find_church(id, current_user) when is_integer(id) do
    with {:ok, query} <- Auth.check(Church, current_user), do: Repo.find(query, id)
  end

  @doc """
  Updates a church.
  """
  def update_church(%Church{} = church, attrs, current_user) do
    with {:ok, church} <- Auth.check(church, current_user) do
      church
      |> Church.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a Church.
  """
  def delete_church(%Church{} = church, current_user) do
    with {:ok, church} <- Auth.check(church, current_user) do
      Repo.delete(church)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking church changes.
  """
  def change_church(%Church{} = church, current_user) do
    with {:ok, church} <- Auth.check(church, current_user) do
      {:ok, Church.changeset(church, %{})}
    end
  end

  @doc """
  Returns the list of users.
  """
  def list_users(current_user) do
    with {:ok, query} <- Auth.check(User, current_user) do
      query
      |> User.order()
      |> Repo.list()
    end
  end

  @doc """
  Gets a single user.
  """
  def find_user(id, current_user) do
    with {:ok, query} <- Auth.check(User, current_user), do: Repo.find(query, id)
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs, current_user) do
    with {:ok, user} <- Auth.check(user, current_user) do
      user
      |> User.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a User.
  """
  def delete_user(%User{} = user, current_user) do
    with {:ok, user} <- Auth.check(user, current_user), do: Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, current_user) do
    with {:ok, user} <- Auth.check(user, current_user), do: {:ok, User.changeset(user, %{})}
  end
end
