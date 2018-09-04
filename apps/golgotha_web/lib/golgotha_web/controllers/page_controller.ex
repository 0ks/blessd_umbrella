defmodule GolgothaWeb.PageController do
  use GolgothaWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
