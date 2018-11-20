defmodule BlessdWeb.ConfirmationController do
  use BlessdWeb, :controller

  alias Blessd.Confirmation
  alias BlessdWeb.ConfirmationMailer
  alias BlessdWeb.Session

  def create(conn, _params) do
    case ConfirmationMailer.send(conn.assigns.current_user) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Confirmation email sent."))
        |> redirect(to: Routes.dashboard_path(conn, :index, user.church.identifier))

      {:error, reason} ->
        conn
        |> put_flash(:error, error_message(reason))
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def show(conn, %{"church_identifier" => identifier, "id" => token}) do
    case Confirmation.confirm(token, identifier) do
      {:ok, user} ->
        conn
        |> Session.put_user(user)
        |> put_flash(:info, gettext("Email confirmed successfully."))
        |> redirect(to: Routes.dashboard_path(conn, :index, user.church.identifier))

      {:error, reason} ->
        conn
        |> put_flash(:error, error_message(reason))
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  defp error_message(%Ecto.Changeset{errors: errors}), do: error_message(errors)

  defp error_message(:not_found) do
    gettext("The given confirmation token does not refer to any user.")
  end

  defp error_message([{:confirmation_token, {_, [validation: :expired]}} | _]) do
    gettext("The given confirmation token is expired, please request another confirmation email.")
  end

  defp error_message([{:confirmation_token, {_, [validation: :format]}} | _]) do
    gettext("The given confirmation token is invalid.")
  end

  defp error_message([_ | t]), do: error_message(t)
end
