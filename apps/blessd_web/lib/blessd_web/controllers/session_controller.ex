defmodule BlessdWeb.SessionController do
  use BlessdWeb, :controller

  alias Blessd.Authentication
  alias BlessdWeb.Session

  def new(conn, _params) do
    render(
      conn,
      "new.html",
      changeset: Authentication.new_session(),
      users: Session.list_users(conn)
    )
  end

  def create(conn, %{"session" => session_params}) do
    case Authentication.authenticate(session_params) do
      {:ok, session} ->
        conn
        |> Session.put_user(session.user)
        |> redirect(to: Routes.person_path(conn, :index, session.church.identifier))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    conn
    |> Session.delete_user()
    |> redirect(to: "/")
  end
end
