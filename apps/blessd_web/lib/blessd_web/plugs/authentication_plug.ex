defmodule BlessdWeb.AuthenticationPlug do
  import Plug.Conn
  import BlessdWeb.Gettext
  import Phoenix.Controller

  alias Blessd.Auth

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :current_user_id) do
      nil ->
        conn
        |> put_flash(:error, gettext("This page can only be accessed when signed in."))
        |> redirect(to: "/")
        |> halt()

      user_id ->
        user = Auth.get_user!(user_id, conn.params["church_identifier"])

        conn
        |> assign(:current_user, user)
        |> assign(
          :current_user_token,
          Phoenix.Token.sign(conn, "user socket", {user.id, user.church.id})
        )
    end
  end
end
