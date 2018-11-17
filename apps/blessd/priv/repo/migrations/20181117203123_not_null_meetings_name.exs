defmodule Blessd.Repo.Migrations.NotNullMeetingsName do
  use Ecto.Migration

  import Ecto.Query

  alias Blessd.Repo

  def up do
    "meetings"
    |> update([m], set: [name: fragment("'Meeting #' || ?", m.id)])
    |> Repo.update_all([])

    alter table(:meetings) do
      modify :name, :string, null: false
    end
  end

  def down do
    alter table(:meetings) do
      modify :name, :string, null: true
    end
  end
end
