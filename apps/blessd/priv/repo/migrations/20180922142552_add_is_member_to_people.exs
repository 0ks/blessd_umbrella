defmodule Blessd.Repo.Migrations.AddIsMemberToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add(:is_member, :boolean)
    end

    create(index(:people, :is_member))
  end
end
