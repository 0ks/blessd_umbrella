defmodule Blessd.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Blessd.Repo
  alias Blessd.Accounts.Church

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
  Creates a church.
  """
  def create_church(attrs) do
    %Church{}
    |> Church.changeset(attrs)
    |> Repo.insert()
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
end
