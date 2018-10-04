defmodule Blessd.Observance.Person do
  use Ecto.Schema

  schema "people" do
    field(:email, :string)
    field(:name, :string)

    timestamps()
  end
end
