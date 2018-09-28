defmodule Blessd.Person.Validations do
  @moduledoc """
  Validations for people
  """

  import Ecto.Changeset

  @doc false
  def basic(changeset) do
    validate_required(changeset, [:name, :is_member])
  end
end
