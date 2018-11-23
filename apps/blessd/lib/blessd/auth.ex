defmodule Blessd.Auth do
  alias Blessd.Auth.Churches
  alias Blessd.Auth.Users

  @doc """
  Gets a single church by id or slug.

  Raises `Ecto.NoResultsError` if the Church does not exist.
  """
  def find_church(slug_or_id), do: Churches.find(slug_or_id)

  @doc """
  Gets a single user by id and church.

  Raises `Ecto.NoResultsError` if the Church does not exist.
  """
  def find_user(id, church), do: Users.find(id, church)

  @doc """
  Check if the given module, query or resource is from the
  given user and it's church.
  """
  def check_user(resource, user), do: Users.check(resource, user)

  @doc """
  Check if the given module, query or resource is from the
  given church.
  """
  def check_church(resource, church), do: Churches.check(resource, church)
end
