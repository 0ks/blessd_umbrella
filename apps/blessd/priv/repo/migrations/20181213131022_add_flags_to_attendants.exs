defmodule Blessd.Repo.Migrations.AddFlagsToAttendants do
  use Ecto.Migration

  def change do
    alter table(:attendants) do
      add(:present, :boolean, default: true)
      add(:first_time_visitor, :boolean, default: false)
    end

    create index(:attendants, [:church_id, :present])
    create index(:attendants, [:church_id, :first_time_visitor])
  end
end
