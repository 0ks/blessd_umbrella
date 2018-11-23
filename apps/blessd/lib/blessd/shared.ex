defmodule Blessd.Shared do
  @moduledoc """
  Inside this context we have a list of secondary context
  shared by all the other contexts. Its only purpose is
  to hold the functions that can be reused accross
  contexts.

  Warning: just put something inside this context if you
  have a reason for it, please do not put it here because
  "you're for sure going to reuse it in the future", wait
  for the reuse opportunity to come, and then move the
  functions here.
  """

  alias Blessd.Shared.Churches
  alias Blessd.Shared.Churches.Church
  alias Blessd.Shared.Users
  alias Blessd.Shared.Users.User

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
  Authorize if the given module, query or resource is from the
  given user or church,
  """
  def authorize(resource, %User{} = user), do: Users.authorize(resource, user)
  def authorize(resource, %Church{} = user), do: Churches.authorize(resource, user)
end
