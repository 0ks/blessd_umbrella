defmodule Blessd.Accounts.User do
  use Ecto.Schema

  import Blessd.Changeset.User
  import Ecto.Query

  alias Blessd.Accounts.User
  alias Blessd.Auth.Church

  schema "users" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:email, :string)
    field(:invitation_token, :string)
    field(:confirmation_token, :string)
    field(:confirmed_at, :utc_datetime)

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs)
    |> validate_all()
    |> update_confirmed_at()
  end

  defp update_confirmed_at(%Ecto.Changeset{changes: %{email: _}} = cs), do: put_confirmation(cs)
  defp update_confirmed_at(changeset), do: changeset

  @doc false
  def invitation_pending?(%User{} = user), do: user.invitation_token != nil

  @doc false
  def invitation_expired?(%User{} = user) do
    invitation_pending?(user) and expired_token?(user.invitation_token)
  end

  @doc false
  def order(query), do: order_by(query, [u], u.name)
end
