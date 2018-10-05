defmodule Blessd.Memberships.Person do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Memberships.Person

  schema "people" do
    belongs_to(:church, Church)

    field(:email, :string)
    field(:name, :string)
    field(:is_member, :boolean)

    timestamps()
  end

  @doc false
  def changeset(%Person{} = person, attrs) do
    person
    |> cast(attrs, [:name, :email, :is_member])
    |> normalize_email()
    |> validate_required([:church_id, :name, :is_member])
    |> validate_format(:email, ~r/@/)
  end

  defp normalize_email(%Ecto.Changeset{changes: %{email: email}} = changeset) when email != nil do
    new_email =
      email
      |> String.downcase()
      |> String.trim()

    put_change(changeset, :email, new_email)
  end

  defp normalize_email(changeset), do: changeset

  def order(query), do: order_by(query, [p], p.name)
end
