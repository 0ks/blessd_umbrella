defmodule Blessd.Repo.Migrations.AddCustomDataToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :custom_data, :map, default: "{}"
    end
  end
end
