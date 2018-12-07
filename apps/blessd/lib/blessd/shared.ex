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
  alias Blessd.Shared.CustomData
  alias Blessd.Shared.Fields
  alias Blessd.Shared.Users
  alias Blessd.Shared.Users.User

  @doc """
  Gets a single church by id or slug.
  """
  def find_church(slug_or_id), do: Churches.find(slug_or_id)

  @doc """
  Gets a single user by id and church.
  """
  def find_user(id, church), do: Users.find(id, church)

  @doc """
  Authorize if the given module, query or resource is from the
  given user or church.
  """
  def authorize(resource, %User{} = user), do: Users.authorize(resource, user)
  def authorize(resource, %Church{} = user), do: Churches.authorize(resource, user)

  @doc """
  Build a changeset to change the custom_data, applying validations
  from the given resource fields
  """
  def custom_data_changeset(resource, custom_data, attrs, church_id) do
    CustomData.changeset(resource, custom_data, attrs, church_id)
  end

  @doc """
  Puts a custom data changeset on the given resource changeset
  """
  def put_custom_data(changeset, field, resource, attrs) do
    CustomData.put_change(changeset, field, resource, attrs)
  end

  @doc """
  List custom fields
  """
  def list_custom_fields(resource, current_user), do: Fields.list(resource, current_user)

  @doc """
  Returns the custom field name
  """
  def custom_field_name(field), do: Fields.name(field)
end
