defmodule Blessd.PasswordReset.Credential do
  use Ecto.Schema

  import Blessd.Shared.Credentials.Credential
  import Ecto.Query

  alias Blessd.Shared.Churches.Church
  alias Blessd.PasswordReset.Credential
  alias Blessd.PasswordReset.User

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
  def by_user(query, %User{id: user_id}), do: by_user(query, user_id)
  def by_user(query, user_id), do: where(query, [t], t.user_id == ^user_id)

  @doc false
  def password(query), do: where(query, [t], t.source == "password")

  @doc false
  def preload(query), do: preload(query, [:user, :church])
end
