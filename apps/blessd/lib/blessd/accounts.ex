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
  def get_church!(identifier) when is_binary(identifier) do
    case Integer.parse(identifier) do
      {id, _} -> get_church!(id)
      :error -> Repo.get_by!(Church, identifier: identifier)
    end
  end

  def get_church!(id) when is_integer(id) do
    Repo.get!(Church, id)
  end

  @doc """
  Updates a church.
  """
  def update_church(%Church{} = church, attrs) do
    church
    |> Church.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Church.
  """
  def delete_church(%Church{} = church) do
    Repo.delete(church)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking church changes.
  """
  def change_church(%Church{} = church) do
    Church.changeset(church, %{})
  end

  @doc """
  Returns the list of users.
  """
  def list_users(church) do
    User
    |> Auth.check!(church)
    |> User.order()
    |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user!(id, church) do
    User
    |> Auth.check!(church)
    |> Repo.get!(id)
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs, church) do
    user
    |> Auth.check!(church)
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.
  """
  def delete_user(%User{} = user, church) do
    user
    |> Auth.check!(church)
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, church) do
    user
    |> Auth.check!(church)
    |> User.changeset(%{})
  end
end
