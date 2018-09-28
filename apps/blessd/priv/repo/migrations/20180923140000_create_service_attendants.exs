defmodule Blessd.Repo.Migrations.CreateServiceAttendants do
  use Ecto.Migration

  def change do
    create table(:service_attendants) do
      add(:service_id, references(:services))
      add(:person_id, references(:people))
      add(:is_present, :boolean)

      timestamps()
    end

    create(index(:service_attendants, [:service_id]))
    create(index(:service_attendants, [:person_id]))
    create(unique_index(:service_attendants, [:service_id, :person_id]))
  end
end
