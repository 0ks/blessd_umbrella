defmodule Blessd.ChurchRecovery.Users.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Shared.Churches.Church
  alias Blessd.ChurchRecovery.Credentials.Credential
  alias Blessd.ChurchRecovery.Users.User

  schema "users" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:email, :string)

    has_many(:credentials, Credential)

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required(:email)
  end
end
