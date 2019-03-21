defmodule Blessd.Signup.Church do
  use Ecto.Schema

  alias Blessd.Signup.Church
  alias Blessd.Shared.Churches.Church, as: SharedChurch

  schema "churches" do
    field(:name, :string)
    field(:slug, :string)
    field(:timezone, :string)
    field(:language, :string)

    timestamps()
  end

  @doc false
  def changeset(%Church{} = church, attrs), do: SharedChurch.changeset(church, attrs)
end
