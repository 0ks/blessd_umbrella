defmodule Blessd.Repo.Migrations.AddPasswordResetFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_reset_token, :string
    end

    create index(:users, [:church_id, :password_reset_token])
  end
end
