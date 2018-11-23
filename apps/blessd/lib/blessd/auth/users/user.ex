defmodule Blessd.Auth.Users.User do
  use Ecto.Schema

  alias Blessd.Auth.Churches.Church

  schema "users" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:email, :string)
    field(:confirmed_at, :utc_datetime)
  end
end
