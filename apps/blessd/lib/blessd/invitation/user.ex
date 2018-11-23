defmodule Blessd.Invitation.User do
  use Ecto.Schema

  import Blessd.Shared.Users.User
  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Invitation.User

  schema "users" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:email, :string)
    field(:invitation_token, :string)
    field(:confirmed_at, :utc_datetime)

    timestamps()
  end

  @doc false
  def invite_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email, name: :users_church_id_email_index)
    |> put_invitation()
  end

  @doc false
  def reinvite_changeset(%User{} = user) do
    user
    |> change(%{})
    |> validate_required(:invitation_token)
    |> put_invitation()
  end

  @doc false
  def accept_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required(:name)
    |> put_invited_at()
  end

  @doc false
  def preload(query) do
    preload(query, [u], :church)
  end
end
