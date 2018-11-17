defmodule Blessd.Repo.Migrations.CreateMeetingOccurrences do
  use Ecto.Migration

  def up do
    create table(:meeting_occurrences) do
      add :church_id, references(:churches, on_delete: :delete_all), null: false

      add :meeting_id, references(:meetings, on_delete: :delete_all), null: false
      add :date, :date, null: false

      timestamps()
    end

    create index(:meeting_occurrences, [:church_id])

    alter table(:meetings) do
      remove :date
    end
  end

  def down do
    alter table(:meetings) do
      add :date, :date
    end

    drop index(:meeting_occurrences, [:church_id])

    drop table(:meeting_occurrences)
  end
end
