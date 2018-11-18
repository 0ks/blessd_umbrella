defmodule Blessd.Repo.Migrations.ChangeAttendantsParentToOccurrences2 do
  use Ecto.Migration

  import Ecto.Query

  alias Blessd.Repo

  def up do
    "attendants"
    |> join(:inner, [a], m in "meetings", on: m.id == a.meeting_id)
    |> join(:inner, [a, m], o in "meeting_occurrences", on: m.id == o.meeting_id)
    |> update([a, m, o], set: [meeting_occurrence_id: o.id])
    |> Repo.update_all([])

    drop constraint(:attendants, :attendants_meeting_occurrence_id_fkey)

    alter table(:attendants) do
      remove :meeting_id

      modify :meeting_occurrence_id, references(:meeting_occurrences, on_delete: :delete_all),
        null: false
    end
  end

  def down do
    alter table(:attendants) do
      add :meeting_id, references(:services, on_delete: :delete_all), null: false
      remove :meeting_occurrence_id
    end
  end
end
