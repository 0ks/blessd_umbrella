defmodule Blessd.Repo.Migrations.RenameServicesToMeetings do
  use Ecto.Migration

  def change do
    rename table(:services), to: table(:meetings)

    rename table(:attendants), :service_id, to: :meeting_id
  end
end
