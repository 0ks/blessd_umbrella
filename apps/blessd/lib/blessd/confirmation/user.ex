defmodule Blessd.Confirmation.User do
  use Ecto.Schema

  import Blessd.Shared.Users.User
  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Confirmation.User

  schema "users" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:email, :string)
    field(:confirmation_token, :string)
    field(:confirmed_at, :utc_datetime)

    timestamps()
  end

  @doc false
  def token_changeset(%User{} = user) do
    user
    |> change(%{})
    |> put_confirmation()
  end

  @doc false
  def confirm_changeset(%User{} = user) do
    user
    |> change(%{})
    |> put_confirmed_at()
  end

  @doc false
  def preload(query) do
    preload(query, [u], :church)
  end
end
