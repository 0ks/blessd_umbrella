defmodule Blessd.PasswordReset.User do
  use Ecto.Schema

  import Blessd.Changeset.User
  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Church
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
  def by_token(query, token), do: where(query, [u], u.password_reset_token == ^token)

  @doc false
  def by_email(query, email), do: where(query, [u], u.email == ^email)

  @doc false
  def preload(query), do: preload(query, [u], :church)
end
