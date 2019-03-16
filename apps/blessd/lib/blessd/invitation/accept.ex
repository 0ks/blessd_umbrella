defmodule Blessd.Invitation.Accept do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Invitation.Accept
  alias Blessd.Invitation.Credential
  alias Blessd.Invitation.User

  embedded_schema do
    belongs_to(:user, User, on_replace: :update)
    belongs_to(:credential, Credential, on_replace: :update)
  end

  @doc false
  def changeset(%Accept{} = accept, attrs) do
    accept
    |> cast(attrs, [])
    |> cast_assoc(:user, required: true, with: &User.accept_changeset/2)
    |> cast_assoc(:credential, required: true)
  end
end
