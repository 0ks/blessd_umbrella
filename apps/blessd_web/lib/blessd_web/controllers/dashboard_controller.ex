defmodule BlessdWeb.DashboardController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, _params) do
    user = conn.assigns.current_user

    with {:ok, todays_meetings} <-
           Observance.list_meeting_occurrences(user, filter: [date: Date.utc_today()]) do
      render(conn, "index.html", resources: %{user: user, todays_meetings: todays_meetings})
    end
  end
end
