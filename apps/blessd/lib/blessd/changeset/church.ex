defmodule Blessd.Changeset.Church do
  import Ecto.Changeset

  @doc false
  def changeset(church, attrs) do
    church
    |> cast(attrs, [:name, :identifier])
    |> validate_required([:name, :identifier])
    |> validate_format(:identifier, ~r/^[a-z0-9_-]+$/)
    |> unique_constraint(:identifier)
  end
end
