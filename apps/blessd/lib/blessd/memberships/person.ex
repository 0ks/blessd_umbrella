defmodule Blessd.Memberships.Person do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Person.Validations

  schema "people" do
    field(:email, :string)
    field(:name, :string)
    field(:is_member, :boolean)

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:name, :email, :is_member])
    |> Validations.basic()
  end
end
