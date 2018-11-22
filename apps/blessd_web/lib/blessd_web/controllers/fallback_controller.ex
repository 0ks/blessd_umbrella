defmodule BlessdWeb.FallbackController do
  use Phoenix.Controller

  import BlessdWeb.Gettext

  alias BlessdWeb.Router.Helpers, as: Routes

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> put_view(BlessdWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> put_view(BlessdWeb.ErrorView)
    |> render(:"403")
  end

  def call(conn, {:error, :unconfirmed}) do
    conn
    |> put_flash(
      :error,
      gettext("""
      You must confirm your email first. Please check your inbox,
      request another email or change to a correct email address.
      """)
    )
    |> redirect(to: Routes.dashboard_path(conn, :index, conn.assigns.current_user.church.slug))
  end
end
