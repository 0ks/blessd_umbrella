defmodule Blessd.Changeset.Church do
  import Ecto.Changeset

  @doc false
  def changeset(church, attrs) do
    church
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9_-]+$/)
    |> unique_constraint(:slug)
  end
end
