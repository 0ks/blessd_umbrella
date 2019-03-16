defmodule Blessd.Repo.Migrations.RenameOldIndexes do
  use Ecto.Migration

  def up do
    execute("ALTER INDEX churches_identifier_index RENAME TO churches_slug_index")
  end

  def down do
    execute("ALTER INDEX churches_slug_index RENAME TO churches_identifier_index")
  end
end
