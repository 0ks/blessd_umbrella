defmodule Blessd.Service.Validations do
  @moduledoc """
  Validations for services
  """

  import Ecto.Changeset

  @doc false
  def basic(changeset) do
    validate_required(changeset, [:date])
  end
end
