defmodule Blessd.Signup.User do
  use Ecto.Schema

  import Blessd.Shared.Users.User

  alias Blessd.Signup.Church
  alias Blessd.Signup.Credential
  alias Blessd.Signup.User

  schema "users" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:email, :string)
    field(:confirmation_token, :string)
    field(:confirmed_at, :utc_datetime)

    has_many(:credentials, Credential)

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs)
    |> put_confirmation()
    |> validate_all()
  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs)
    |> validate_basic()
  end
end
