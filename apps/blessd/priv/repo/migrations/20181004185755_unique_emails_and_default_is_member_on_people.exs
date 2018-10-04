defmodule Blessd.Repo.Migrations.UniqueEmailsAndDefaultIsMemberOnPeople do
  use Ecto.Migration

  def up do
    alter table(:people) do
      modify(:is_member, :boolean, default: false)
    end

    alter table(:services) do
      remove(:name)
    end
  end

  def down do
    alter table(:people) do
      modify(:is_member, :boolean)
    end

    alter table(:services) do
      add(:name, :string)
    end
  end
end
