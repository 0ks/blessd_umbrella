defmodule BlessdWeb.ConfirmationController do
  use BlessdWeb, :controller

  alias Blessd.Confirmation

  def create(conn, %{"church_identifier" => identifier, "token" => token}) do
    case Confirmation.confirm(token, identifier) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, gettext("Email confirmed successfully."))
        |> redirect(to: Routes.person_path(conn, :index, user.church.identifier))

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
