defmodule Blessd.Repo.Migrations.AddPositionToCustomFields do
  use Ecto.Migration

  def change do
    alter table(:custom_fields) do
      add :position, :integer

      timestamps()
    end

    create index(:custom_fields, [:church_id, :position])
  end
end
