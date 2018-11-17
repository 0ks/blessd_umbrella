defmodule Blessd.Repo.Migrations.RenameServiceAttendantsToAttendants do
  use Ecto.Migration

  def change do
    rename table(:service_attendants), to: table(:attendants)
  end
end
