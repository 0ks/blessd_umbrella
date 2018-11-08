defmodule Blessd.Authentication.Credential do
  use Ecto.Schema

  alias Blessd.Auth.Church
  alias Blessd.Authentication.User

  schema "credentials" do
    belongs_to(:church, Church)
    belongs_to(:user, User)

    field(:source, :string)
    field(:token, :string)
  end
end
