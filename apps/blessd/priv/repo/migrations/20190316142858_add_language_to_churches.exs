defmodule Blessd.Repo.Migrations.AddLanguageToChurches do
  use Ecto.Migration

  def change do
    alter table(:churches) do
      add(:language, :string, default: "en")
    end
  end
end
