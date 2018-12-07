defmodule Blessd.PasswordReset.TokenData do
  use Ecto.Schema

  import Blessd.Shared.EmailValidator
  import Ecto.Changeset

  alias Blessd.PasswordReset.TokenData

  embedded_schema do
    field(:church_slug, :string)
    field(:email, :string)
  end

  @doc false
  def changeset(%TokenData{} = token_data, attrs) do
    token_data
    |> cast(attrs, [:church_slug, :email])
    |> normalize_email(:email)
    |> validate_required([:church_slug, :email])
    |> validate_email(:email)
  end
end
