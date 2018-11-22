defmodule BlessdWeb.InvitationController do
  use BlessdWeb, :controller

  alias Blessd.Invitation
  alias BlessdWeb.InvitationMailer
  alias BlessdWeb.Session

  def new(conn, _params) do
    with current_user = conn.assigns.current_user,
         {:ok, user} <- Invitation.new_user(current_user),
         {:ok, changeset} <- Invitation.change_user(user, current_user) do
      render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"user" => user_params}) do
    with current_user = conn.assigns.current_user,
         {:ok, user} <- Invitation.invite(user_params, current_user),
         :ok = InvitationMailer.send(user, current_user) do
      conn
      |> put_flash(:info, gettext("User invited successfully."))
      |> redirect(to: Routes.user_path(conn, :index, user.church))
    else
      {:error, %Ecto.Changeset{} = changeset} -> render(conn, "new.html", changeset: changeset)
      {:error, reason} -> {:error, reason}
    end
  end

  def create(conn, %{"token" => token}) do
    with current_user = conn.assigns.current_user,
         {:ok, user} <- Invitation.reinvite(token, current_user),
         :ok = InvitationMailer.send(user, current_user) do
      conn
      |> put_flash(:info, gettext("User invited successfully."))
      |> redirect(to: Routes.user_path(conn, :index, user.church))
    else
      {:error, %Ecto.Changeset{} = changeset} -> render(conn, "new.html", changeset: changeset)
      {:error, reason} -> {:error, reason}
    end
  end

  def edit(conn, %{"church_slug" => slug, "id" => token}) do
    with {:ok, user} <- Invitation.validate_token(token, slug),
         {:ok, accept} <- Invitation.new_accept(user),
         {:ok, changeset} <- Invitation.change_accept(accept) do
      render(conn, "edit.html", changeset: changeset)
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, error_message(reason))
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def update(conn, %{"church_slug" => slug, "id" => token, "accept" => attrs}) do
    with {:ok, user} <- Invitation.accept(token, attrs, slug) do
      conn
      |> Session.put_user(user)
      |> put_flash(:info, gettext("Invitation accepted succesfully."))
      |> redirect(to: Routes.dashboard_path(conn, :index, user.church))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp error_message(%Ecto.Changeset{errors: errors}), do: error_message(errors)

  defp error_message(:not_found) do
    gettext("The given invitation token does not refer to any user.")
  end

  defp error_message([{:invitation_token, {_, [validation: :expired]}} | _]) do
    gettext("""
    The given invitation token is invalid or expired,
    please request another invitation email.
    """)
  end

  defp error_message([_ | t]), do: error_message(t)
end
