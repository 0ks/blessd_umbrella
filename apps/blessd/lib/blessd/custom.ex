defmodule Blessd.Custom do
  @moduledoc """
  Functions for dealing with customizations in the system.
  """

  alias Blessd.Custom.Fields

  @doc """
  Returns the list of fields.
  """
  def list_fields(current_user), do: Fields.list(current_user)

  @doc """
  Builds a custom field changeset ready to insert.
  """
  def new_field_changeset(current_user), do: Fields.new_changeset(current_user)

  @doc """
  Creates a field.
  """
  def create_field(attrs, current_user), do: Fields.create(attrs, current_user)

  @doc """
  Builds a custom field changeset ready to use update.
  """
  def edit_field_changeset(field, current_user), do: Fields.edit_changeset(field, current_user)

  @doc """
  Updates a field.
  """
  def update_field(field, attrs, current_user), do: Fields.update(field, attrs, current_user)

  @doc """
  Deletes a field.
  """
  def delete_field(field, current_user), do: Fields.delete(field, current_user)
end
