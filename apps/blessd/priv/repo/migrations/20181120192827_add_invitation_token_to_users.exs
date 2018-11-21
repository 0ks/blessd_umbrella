defmodule Blessd.Repo.Migrations.AddInvitationTokenToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :invitation_token, :string
    end

    create index(:users, [:church_id, :invitation_token])
  end
end
