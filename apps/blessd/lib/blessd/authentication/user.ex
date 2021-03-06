defmodule Blessd.Authentication.User do
  use Ecto.Schema

  alias Blessd.Shared.Churches.Church

  schema "users" do
    belongs_to(:church, Church)

    field(:email, :string)
  end
end
