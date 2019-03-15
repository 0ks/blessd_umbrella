defmodule Blessd.Shared.Churches.Church do
  use Ecto.Schema

  import Ecto.Changeset

  schema "churches" do
    field(:name, :string)
    field(:slug, :string)
    field(:timezone, :string)
  end

  @doc false
  def changeset(church, attrs) do
    church
    |> cast(attrs, [:name, :slug, :timezone])
    |> validate_required([:name, :slug, :timezone])
    |> validate_format(:slug, ~r/^[a-z0-9_-]+$/)
    |> unique_constraint(:slug)
    |> validate_inclusion(:timezone, Timex.timezones())
  end
end
