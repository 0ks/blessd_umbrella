defmodule Blessd.Repo.Migrations.AddTimezoneToChurches do
  use Ecto.Migration

  def change do
    alter table(:churches) do
      add(:timezone, :string, default: "UTC")
    end
  end
end
