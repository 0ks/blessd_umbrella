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

  Raises `Ecto.NoResultsError` if the Church does not exist.
  """
  def get_church!(identifier, current_user) when is_binary(identifier) do
    case Integer.parse(identifier) do
      {id, _} ->
        get_church!(id, current_user)

      :error ->
        Church
        |> Auth.check!(current_user)
        |> Repo.get_by!(identifier: identifier)
    end
  end

  def get_church!(id, current_user) when is_integer(id) do
    Church
    |> Auth.check!(current_user)
    |> Repo.get!(id)
  end

  @doc """
  Updates a church.
  """
  def update_church(%Church{} = church, attrs, current_user) do
    church
    |> Auth.check!(current_user)
    |> Church.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Church.
  """
  def delete_church(%Church{} = church, current_user) do
    church
    |> Auth.check!(current_user)
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking church changes.
  """
  def change_church(%Church{} = church, current_user) do
    church
    |> Auth.check!(current_user)
    |> Church.changeset(%{})
  end

  @doc """
  Returns the list of users.
  """
  def list_users(current_user) do
    User
    |> Auth.check!(current_user)
    |> User.order()
    |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user!(id, current_user) do
    User
    |> Auth.check!(current_user)
    |> Repo.get!(id)
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs, current_user) do
    user
    |> Auth.check!(current_user)
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.
  """
  def delete_user(%User{} = user, current_user) do
    user
    |> Auth.check!(current_user)
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, current_user) do
    user
    |> Auth.check!(current_user)
    |> User.changeset(%{})
  end
end
