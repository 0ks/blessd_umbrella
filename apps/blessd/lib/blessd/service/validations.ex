defmodule Blessd.ServiceAttendant.Validations do
  @moduledoc """
  Validations for services
  """

  import Ecto.Changeset

  @doc false
  def basic(changeset) do
    validate_required(changeset, [:service_id, :person_id, :is_present])
  end
end
