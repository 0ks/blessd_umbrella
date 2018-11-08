defmodule Blessd.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users) do
      add(:church_id, references(:churches, on_delete: :delete_all), null: false)

      add(:name, :string)
      add(:email, :string)

      timestamps()
    end

    create(index(:users, [:church_id]))
    create(unique_index(:users, [:church_id, :email]))

    create table(:credentials) do
      add(:church_id, references(:churches, on_delete: :delete_all), null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      add(:source, :string, null: false, default: "password")
      add(:token, :string, null: false)

      timestamps()
    end

    create(index(:credentials, [:church_id]))
    create(unique_index(:credentials, [:church_id, :user_id, :source]))

    alter table(:people) do
      remove(:church_id)
      add(:church_id, references(:churches, on_delete: :delete_all), null: false)
    end

    alter table(:services) do
      remove(:church_id)
      add(:church_id, references(:churches, on_delete: :delete_all), null: false)
    end

    alter table(:service_attendants) do
      remove(:church_id)
      add(:church_id, references(:churches, on_delete: :delete_all), null: false)
    end
  end

  def down do
    drop(table(:credentials))
    drop(table(:users))

    alter table(:people) do
      remove(:church_id)
      add(:church_id, references(:churches, on_delete: :delete_all))
    end

    alter table(:services) do
      remove(:church_id)
      add(:church_id, references(:churches, on_delete: :delete_all))
    end

    alter table(:service_attendants) do
      remove(:church_id)
      add(:church_id, references(:churches, on_delete: :delete_all))
    end
  end
end
