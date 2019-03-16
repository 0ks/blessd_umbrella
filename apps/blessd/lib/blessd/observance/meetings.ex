defmodule Blessd.Observance.Meetings do
  @moduledoc """
  Secondary context for meetings
  """

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Observance.Meetings.Meeting
  alias Blessd.Observance.Meetings.Occurrences
  alias Blessd.Observance.Meetings.Occurrences.Occurrence
  alias Blessd.Repo
  alias Blessd.Shared
  alias Ecto.Multi

  @doc false
  def list(current_user, opts) do
    with {:ok, query} <- Shared.authorize(Meeting, current_user) do
      query
      |> apply_opts(opts)
      |> apply_preload(opts)
      |> order()
      |> Repo.list()
    end
  end

  defp apply_opts(query, []), do: query

  defp apply_opts(query, [{:for_select, true} | rest]) do
    query
    |> select([m], {m.name, m.id})
    |> apply_opts(rest)
  end

  @doc false
  def find(id, current_user) do
    with {:ok, query} <- Shared.authorize(Meeting, current_user) do
      query
      |> apply_preload()
      |> Repo.find(id)
    end
  end

  @doc false
  def create(attrs, current_user) do
    changeset = current_user |> build([]) |> Meeting.changeset(attrs)

    Multi.new()
    |> Multi.insert(:meeting, changeset)
    |> Multi.run(
      :occurrence,
      &Occurrences.insert(&1, &2, attrs["occurrences"]["0"], current_user)
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{meeting: meeting, occurrence: occurrence}} ->
        {:ok, %{meeting | occurrences: [occurrence]}}

      {:error, :meeting, changeset, _} ->
        {:error, changeset}

      {:error, assoc, %Ecto.Changeset{} = child_changeset, _} ->
        changeset
        |> put_assoc(assoc, child_changeset)
        |> apply_action(:insert)

      {:error, _, reason, _} ->
        {:error, reason}
    end
  end

  @doc false
  def update(id, attrs, current_user) do
    with {:ok, meeting} <- find(id, current_user),
         {:ok, meeting} <- Shared.authorize(meeting, current_user) do
      meeting
      |> Meeting.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc false
  def delete(id, current_user) do
    with {:ok, meeting} <- find(id, current_user),
         {:ok, meeting} <- Shared.authorize(meeting, current_user) do
      Repo.delete(meeting)
    end
  end

  @doc false
  def new_changeset(current_user) do
    with {:ok, meeting} <- current_user |> build() |> Shared.authorize(current_user) do
      {:ok, Meeting.changeset(meeting, %{})}
    end
  end

  @doc false
  def edit_changeset(id, current_user) do
    with {:ok, meeting} <- find(id, current_user),
         {:ok, meeting} <- Shared.authorize(meeting, current_user) do
      {:ok, Meeting.changeset(meeting, %{})}
    end
  end

  @doc false
  def build(current_user) do
    occurrence = Occurrences.build(current_user)
    build(current_user, [occurrence])
  end

  @doc false
  def build(current_user, occurrences) do
    %Meeting{
      church_id: current_user.church.id,
      occurrences: occurrences
    }
  end

  @doc false
  def apply_preload(query, opts \\ []) do
    if {:for_select, true} in opts do
      query
    else
      occurrences_query = Occurrences.order(Occurrence)

      preload(query, [s], occurrences: ^occurrences_query)
    end
  end

  @doc false
  def order(query), do: order_by(query, [s], asc: s.name)
end
