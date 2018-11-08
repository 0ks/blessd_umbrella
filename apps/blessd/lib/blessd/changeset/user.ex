defmodule Blessd.Changeset.User do
  import Ecto.Changeset

  alias Blessd.Changeset.Email

  @doc false
  def cast(user, attrs) do
    cast(user, attrs, [:name, :email])
  end

  @doc false
  def validate_basic(changeset) do
    changeset
    |> Email.normalize()
    |> validate_required([:name, :email])
    |> Email.validate()
  end

  @doc false
  def validate_all(changeset) do
    changeset
    |> validate_basic()
    |> validate_required(:church_id)
  end
end
