defmodule Blessd.Accounts.Church do
  use Ecto.Schema

  import Ecto.Changeset

  schema "churches" do
    field(:name, :string)
    field(:identifier, :string)

    timestamps()
  end

  @doc false
  def changeset(church, attrs) do
    church
    |> cast(attrs, [:name, :identifier])
    |> validate_required([:name, :identifier])
    |> validate_format(:identifier, ~r/^[a-z0-9_-]+$/)
    |> unique_constraint(:identifier)
  end
end
