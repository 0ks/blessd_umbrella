defmodule Blessd.Confirmation.User do
  use Ecto.Schema

  import Ecto.Changeset

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
    |> change(%{confirmation_token: generate_token()})
    |> validate_required(:confirmation_token)
  end

  @doc false
  def confirm_changeset(%User{} = user) do
    user
    |> change(%{confirmation_token: nil, confirmed_at: DateTime.utc_now()})
    |> validate_required(:confirmed_at)
  end

  defp generate_token(length \\ 50) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
    |> String.slice(0, length)
  end
end
