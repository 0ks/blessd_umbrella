defmodule Blessd.Signup.Registration do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Signup.Church
  alias Blessd.Signup.Credential
  alias Blessd.Signup.User
  alias Blessd.Signup.Registration

  embedded_schema do
    belongs_to(:church, Church)
    belongs_to(:user, User)
    belongs_to(:credential, Credential)
  end

  @doc false
  def changeset(%Registration{} = registration, attrs) do
    registration
    |> cast(attrs, [])
    |> cast_assoc(:church, required: true)
    |> cast_assoc(:user, required: true, with: &User.registration_changeset/2)
    |> cast_assoc(:credential, required: true, with: &Credential.registration_changeset/2)
  end
end
