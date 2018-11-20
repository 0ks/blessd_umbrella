defmodule BlessdWeb.DashboardController do
  use BlessdWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", resources: %{user: conn.assigns.current_user})
  end
end
