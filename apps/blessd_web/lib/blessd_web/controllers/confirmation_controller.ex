defmodule BlessdWeb.ConfirmationController do
  use BlessdWeb, :controller

  alias Blessd.Confirmation

  def create(conn, %{"church_identifier" => identifier, "token" => token}) do
    case Confirmation.confirm(token, identifier) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Email confirmed successfully."))
        |> redirect(to: Routes.person_path(conn, :index, user.church.identifier))

      {:error, :invalid_token} ->
        conn
        |> put_flash(:info, gettext("The given token is invalid."))
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
