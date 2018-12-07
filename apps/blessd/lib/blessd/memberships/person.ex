defmodule Blessd.Memberships.Person do
  use Ecto.Schema

  import Blessd.Shared.EmailValidator
  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Shared
  alias Blessd.Shared.Churches.Church
  alias Blessd.Memberships.Person

  schema "people" do
    belongs_to(:church, Church)

    field(:email, :string)
    field(:name, :string)
    field(:is_member, :boolean)
    field(:custom_data, :map, default: %{})

    timestamps()
  end

  @doc false
  def changeset(%Person{} = person, attrs) do
    person
    |> cast(attrs, [:name, :email, :is_member])
    |> normalize_email(:email)
    |> validate_required([:church_id, :name, :is_member])
    |> validate_email(:email)
    |> Shared.put_custom_data(:custom_data, "person", Map.get(attrs, "custom_data", %{}))
  end

  def order(query), do: order_by(query, [p], p.name)
end
