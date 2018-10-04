defmodule Blessd.Repo.Migrations.CreateServices do
  use Ecto.Migration

  def change do
    create table(:services) do
      add(:name, :string)
      add(:date, :date)

      timestamps()
    end
  end
end
