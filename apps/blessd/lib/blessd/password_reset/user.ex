defmodule Blessd.PasswordReset.User do
  use Ecto.Schema

  import Blessd.Shared.Users.User
  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Shared.Churches.Church
  alias Blessd.PasswordReset.User

  schema "users" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:email, :string)
    field(:password_reset_token, :string)

    timestamps()
  end

  @doc false
  def token_changeset(%User{} = user) do
    user
    |> change(%{})
    |> put_password_reset()
  end

  @doc false
  def reset_changeset(%User{} = user) do
    user
    |> change(%{})
    |> clear_password_reset()
  end

  @doc false
  def preload(query), do: preload(query, [u], :church)
end
