defmodule Blessd.Repo.Migrations.RenameChurchIdentifierToSlug do
  use Ecto.Migration

  def change do
    rename table(:churches), :identifier, to: :slug
  end
end
