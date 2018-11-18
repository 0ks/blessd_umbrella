defmodule Blessd.Repo.Migrations.ChangeAttendantsParentToOccurrences do
  use Ecto.Migration

  def change do
    alter table(:attendants) do
      add :meeting_occurrence_id, references(:meeting_occurrences, on_delete: :delete_all)
    end
  end
end
