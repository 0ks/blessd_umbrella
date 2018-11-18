defmodule Blessd.Repo.Migrations.RemoveMeetingsDate do
  use Ecto.Migration

  import Ecto.Query

  alias Blessd.Repo

  def up do
    occurrences =
      "meetings"
      |> select([m], {m.church_id, m.id, m.date})
      |> Repo.all()
      |> Enum.map(&occurrence_attrs/1)

    Repo.insert_all("meeting_occurrences", occurrences)

    alter table(:meetings) do
      remove :date
    end
  end

  def down do
    alter table(:meetings) do
      add :date, :date
    end
  end

  defp occurrence_attrs({church_id, id, nil}) do
    occurrence_attrs({church_id, id, Date.utc_today()})
  end

  defp occurrence_attrs({church_id, id, date}) do
    %{
      church_id: church_id,
      meeting_id: id,
      date: date,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end
end
