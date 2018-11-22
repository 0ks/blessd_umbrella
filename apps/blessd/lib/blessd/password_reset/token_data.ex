defmodule Blessd.PasswordReset.TokenData do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.PasswordReset.TokenData

  embedded_schema do
    field(:church_identifier, :string)
    field(:email, :string)
  end

  @doc false
  def changeset(%TokenData{} = token_data, attrs) do
    token_data
    |> cast(attrs, [:church_identifier, :email])
    |> validate_required([:church_identifier, :email])
  end
end
