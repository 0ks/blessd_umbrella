defmodule BlessdWeb.AuthenticationPlug do
  import BlessdWeb.Gettext
  import Phoenix.Controller
  import Plug.Conn

  alias BlessdWeb.Session

  def init(opts), do: opts

  def call(conn, _opts) do
    case Session.find_user(conn) do
      {:ok, user} ->
        conn
        |> assign(:current_user, user)
        |> assign(
          :current_user_token,
          Phoenix.Token.sign(conn, "user socket", {user.id, user.church.id})
        )

      {:error, :not_found} ->
        conn
        |> put_flash(:error, gettext("This page can only be accessed when signed in."))
        |> redirect(to: "/sessions/new?church_slug=#{conn.params["church_slug"]}")
        |> halt()
    end
  end
end
