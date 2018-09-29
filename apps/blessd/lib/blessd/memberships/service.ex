defmodule Blessd.Memberships.Service do
  use Ecto.Schema

  schema "services" do
    field(:name, :string)

    timestamps()
  end
end
