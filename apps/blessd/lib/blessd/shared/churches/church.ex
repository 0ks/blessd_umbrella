defmodule Blessd.Shared.Churches.Church do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Shared.Languages

  schema "churches" do
    field(:name, :string)
    field(:slug, :string)
    field(:timezone, :string)
    field(:language, :string)
  end

  @doc false
  def changeset(church, attrs) do
    church
    |> cast(attrs, [:name, :slug, :language, :timezone])
    |> validate_required([:name, :slug, :language, :timezone])
    |> validate_format(:slug, ~r/^[a-z0-9_-]+$/)
    |> unique_constraint(:slug)
    |> validate_inclusion(:timezone, Timex.timezones())
    |> validate_inclusion(:language, Languages.list())
  end
end
