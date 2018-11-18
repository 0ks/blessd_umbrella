defmodule Blessd.Repo.Migrations.AddConfirmationFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :confirmation_token, :string
      add :confirmed_at, :utc_datetime
    end

    create index(:users, [:church_id, :confirmation_token])
  end
end
