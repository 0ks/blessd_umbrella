defmodule BlessdWeb.DashboardController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, params) do
    user = conn.assigns.current_user

    with {:ok, todays_meetings} <- todays_meetings(user),
         {:ok, meetings} <-
           skip_unconfirmed(fn ->
             Observance.list_meetings(user, for_select: true)
           end),
         missed_meeting_id = params["missed_meeting_id"] || first_id(meetings),
         {:ok, most_missed} <-
           skip_unconfirmed(fn ->
             Observance.list_people(
               user,
               filter: "missed",
               date: Blessd.Date.today(user),
               meeting_id: missed_meeting_id,
               limit: 2
             )
           end) do
      render(conn, "index.html",
        resources: %{
          user: user,
          todays_meetings: todays_meetings,
          missed_meeting_id: missed_meeting_id,
          meetings: meetings,
          most_missed: most_missed
        }
      )
    end
  end

  defp first_id([]), do: nil
  defp first_id([{_, id} | _]), do: id

  defp todays_meetings(user) do
    with {:ok, occurrences} <-
           skip_unconfirmed(fn ->
             Observance.list_occurrences(user, filter: [date: Blessd.Date.today(user)])
           end) do
      result =
        occurrences
        |> Stream.map(&{&1, Observance.attendance_stats(&1, user)})
        |> Enum.map(fn {occ, {:ok, stats}} ->
          {occ, stats}
        end)

      {:ok, result}
    end
  end

  defp skip_unconfirmed(func) do
    case func.() do
      {:ok, meetings} -> {:ok, meetings}
      {:error, :unconfirmed} -> {:ok, []}
      other -> other
    end
  end
end
