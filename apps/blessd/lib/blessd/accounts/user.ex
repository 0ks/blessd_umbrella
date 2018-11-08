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

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs)
    |> validate_all()
  end

  def order(query), do: order_by(query, [u], u.name)
end
