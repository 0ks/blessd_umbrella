defmodule Blessd.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Blessd.Accounts.Churches
  alias Blessd.Accounts.Users

  @doc """
  Builds a church changeset to edit.
  """
  def edit_church_changeset(id, current_user), do: Churches.edit_changeset(id, current_user)

  @doc """
  Updates a church.
  """
  def update_church(id, attrs, current_user), do: Churches.update(id, attrs, current_user)

  @doc """
  Deletes a Church.
  """
  def delete_church(id, current_user), do: Churches.delete(id, current_user)

  @doc """
  Returns the list of users.
  """
  def list_users(current_user), do: Users.list(current_user)

  @doc """
  Builds a church changeset to edit.
  """
  def edit_user_changeset(id, current_user), do: Users.edit_changeset(id, current_user)

  @doc """
  Updates a user.
  """
  def update_user(id, attrs, current_user), do: Users.update(id, attrs, current_user)

  @doc """
  Deletes a User.
  """
  def delete_user(id, current_user), do: Users.delete(id, current_user)

  @doc """
  Returns if the current user is authorized to do a given action on a given resource
  """
  def authorized_user?(resource, action, current_user) do
    Users.authorized?(resource, action, current_user)
  end
end
