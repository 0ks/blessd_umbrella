defmodule Blessd.Accounts.Church do
  use Ecto.Schema

  alias Blessd.Accounts.Church
  alias Blessd.Shared.Churches.Church, as: SharedChurch

  schema "churches" do
    field(:name, :string)
    field(:slug, :string)
    field(:timezone, :string)

    timestamps()
  end

  @doc false
  def changeset(%Church{} = church, attrs), do: SharedChurch.changeset(church, attrs)
end
