defmodule Blessd.Repo.Migrations.RenameMeetingOccurrenceIdOnAttendants do
  use Ecto.Migration

  def change do
    rename table("attendants"), :meeting_occurrence_id, to: :occurrence_id
  end
end
