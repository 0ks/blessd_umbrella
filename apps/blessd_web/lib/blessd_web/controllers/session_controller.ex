defmodule BlessdWeb.SessionController do
  use BlessdWeb, :controller

  alias Blessd.Authentication

  def new(conn, _params) do
    render(conn, "new.html", changeset: Authentication.new_session())
  end

  def create(conn, %{"session" => session_params}) do
    case Authentication.authenticate(session_params) do
      {:ok, session} ->
        conn
        |> put_session(:current_user_id, session.user.id)
        |> redirect(to: person_path(conn, :index, session.church.identifier))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: "/")
  end
end
