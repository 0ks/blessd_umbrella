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
  def edit_field_changeset(field_id, current_user) do
    Fields.edit_changeset(field_id, current_user)
  end

  @doc """
  Updates a field.
  """
  def update_field(field_id, attrs, current_user) do
    Fields.update(field_id, attrs, current_user)
  end

  @doc """
  Reorder the given fields to the given sequence
  """
  def reorder_fields(field_ids, current_user), do: Fields.reorder(field_ids, current_user)

  @doc """
  Deletes a field.
  """
  def delete_field(field_id, current_user), do: Fields.delete(field_id, current_user)
end
