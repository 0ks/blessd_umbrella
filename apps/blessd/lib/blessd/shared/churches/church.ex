defmodule Blessd.Shared.Churches.Church do
  use Ecto.Schema

  import Ecto.Changeset

  schema "churches" do
    field(:name, :string)
    field(:slug, :string)
  end

  @doc false
  def changeset(church, attrs) do
    church
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9_-]+$/)
    |> unique_constraint(:slug)
  end
end
