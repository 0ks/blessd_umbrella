defmodule Blessd.Signup.Credential do
  use Ecto.Schema

  import Blessd.Shared.Credentials.Credential

  alias Blessd.Auth.Church
  alias Blessd.Signup.Credential
  alias Blessd.Signup.User

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

  @doc false
  def registration_changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs)
    |> validate_basic()
  end
end
