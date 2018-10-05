defmodule Blessd.Repo.Migrations.CreateChurches do
  use Ecto.Migration

  def change do
    create table(:churches) do
      add(:name, :string)
      add(:identifier, :string)

      timestamps()
    end

    create(unique_index(:churches, [:identifier]))

    alter table(:people) do
      add(:church_id, references(:churches, on_delete: :delete_all))
    end

    drop(index(:people, [:is_member]))

    create(index(:people, [:church_id]))
    create(index(:people, [:church_id, :is_member]))

    alter table(:services) do
      add(:church_id, references(:churches, on_delete: :delete_all))
    end

    create(index(:services, [:church_id]))

    alter table(:service_attendants) do
      add(:church_id, references(:churches, on_delete: :delete_all))
    end

    drop(index(:service_attendants, [:service_id]))
    drop(index(:service_attendants, [:person_id]))
    drop(unique_index(:service_attendants, [:service_id, :person_id]))

    create(index(:service_attendants, [:church_id]))
    create(index(:service_attendants, [:church_id, :service_id]))
    create(index(:service_attendants, [:church_id, :person_id]))
    create(unique_index(:service_attendants, [:church_id, :service_id, :person_id]))
  end
end
