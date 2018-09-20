defmodule BlessdWeb.PageController do
  use BlessdWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
