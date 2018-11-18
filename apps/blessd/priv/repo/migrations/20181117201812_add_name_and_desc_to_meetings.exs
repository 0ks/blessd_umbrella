defmodule Blessd.Repo.Migrations.AddNameAndDescToMeetings do
  use Ecto.Migration

  def change do
    alter table(:meetings) do
      add :name, :string
      add :description, :text
    end

    create unique_index(:meetings, [:church_id, :name])
  end
end
