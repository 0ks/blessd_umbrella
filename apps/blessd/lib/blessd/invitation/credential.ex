defmodule Blessd.Invitation.Credential do
  use Ecto.Schema

  import Blessd.Shared.Credentials.Credential

  alias Blessd.Auth.Church
  alias Blessd.Invitation.Credential
  alias Blessd.Invitation.User

  schema "credentials" do
    belongs_to(:church, Church)
    belongs_to(:user, User)

    field(:source, :string)
    field(:token, :string)

    timestamps()
  end

  @doc false
  def changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs)
    |> validate_all()
  end
end
