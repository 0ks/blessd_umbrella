defmodule Blessd.Accounts.Church do
  use Ecto.Schema

  import Ecto.Changeset

  schema "churches" do
    field(:name, :string)
    field(:subdomain, :string)

    timestamps()
  end

  @doc false
  def changeset(church, attrs) do
    church
    |> cast(attrs, [:name, :subdomain])
    |> validate_required([:name, :subdomain])
    |> validate_format(:subdomain, ~r/^[a-z][a-z0-9_-]+$/)
    |> unique_constraint(:subdomain)
  end
end
