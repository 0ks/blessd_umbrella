defmodule Blessd.Repo.Migrations.CreateCustomFields do
  use Ecto.Migration

  def change do
    create table(:custom_fields) do
      add :church_id, references(:churches, on_delete: :delete_all), null: false

      add :resource, :string, null: false
      add :name, :string, null: false
      add :type, :string, null: false

      add :validations, :map, default: "{}"
    end

    create index(:custom_fields, [:church_id])
    create index(:custom_fields, [:church_id, :resource])
  end
end
