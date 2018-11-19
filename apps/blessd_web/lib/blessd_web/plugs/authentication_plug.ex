defmodule BlessdWeb.AuthenticationPlug do
  import Plug.Conn
  import BlessdWeb.Gettext
  import Phoenix.Controller

  alias BlessdWeb.Session

  def init(opts), do: opts

  def call(conn, _opts) do
    case Session.get_user(conn) do
      nil ->
        conn
        |> put_flash(:error, gettext("This page can only be accessed when signed in."))
        |> redirect(to: "/")
        |> halt()

      user ->
        conn
        |> assign(:current_user, user)
        |> assign(:users, Session.list_users(conn))
        |> assign(
          :current_user_token,
          Phoenix.Token.sign(conn, "user socket", {user.id, user.church.id})
        )
    end
  end
end
