defmodule Blessd.Observance.Person do
  use Ecto.Schema

  import Ecto.Query

  schema "people" do
    field(:church_id, :id)
    field(:email, :string)
    field(:name, :string)
  end

  def select_ids(query), do: select(query, [p], p.id)
end
