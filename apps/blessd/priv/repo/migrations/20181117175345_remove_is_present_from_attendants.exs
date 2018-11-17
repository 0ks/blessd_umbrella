defmodule Blessd.Repo.Migrations.RemoveIsPresentFromAttendants do
  use Ecto.Migration

  def up do
    alter table(:service_attendants) do
      remove(:is_present)
    end
  end

  def down do
    alter table(:service_attendants) do
      add(:is_present, :boolean)
    end
  end
end
