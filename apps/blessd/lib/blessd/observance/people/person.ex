defmodule Blessd.Observance.People.Person do
  use Ecto.Schema

  alias Blessd.Observance.Meetings.Attendants.Attendant

  schema "people" do
    field(:church_id, :id)
    field(:email, :string)
    field(:name, :string)
    field(:is_member, :boolean)

    field(:state, :string, virtual: true)
    field(:missed, :integer, virtual: true)
    field(:already_visited, :boolean, virtual: true)

    has_many(:attendants, Attendant)

    timestamps()
  end
end
