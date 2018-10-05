defmodule BlessdWeb.ChurchPlug do
  import Plug.Conn
  import BlessdWeb.Gettext
  import Phoenix.Controller

  alias Blessd.Auth

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.params["church_identifier"] do
      nil ->
        conn
        |> put_flash(
          :error,
          gettext("This page can only be accessed from inside a church, please login.")
        )
        |> redirect(to: "/")
        |> halt()

      identifier ->
        church = Auth.get_church!(identifier)

        conn
        |> assign(:current_church, church)
        # TODO - move this to user auth and use user.id, not church.id
        |> assign(:user_token, Phoenix.Token.sign(conn, "user socket", church.id))
    end
  end
end
