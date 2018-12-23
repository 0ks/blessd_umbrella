defmodule BlessdWeb.DashboardController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, _params) do
    user = conn.assigns.current_user

    with {:ok, todays_meetings} <-
           Observance.list_meeting_occurrences(user, filter: [date: Date.utc_today()]) do
      meetings_and_stats =
        todays_meetings
        |> Stream.map(&{&1, Observance.attendance_stats(&1, user)})
        |> Stream.map(fn {occ, {:ok, stats}} ->
          {occ, stats}
        end)

      render(conn, "index.html", resources: %{user: user, todays_meetings: meetings_and_stats})
    end
  end
end
