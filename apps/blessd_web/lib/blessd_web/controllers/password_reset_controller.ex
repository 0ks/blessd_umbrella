defmodule BlessdWeb.PasswordResetController do
  use BlessdWeb, :controller

  alias Blessd.PasswordReset
  alias BlessdWeb.PasswordResetMailer
  alias BlessdWeb.Session

  def new(conn, _params) do
    with {:ok, token_data} <- PasswordReset.new_token_data(),
         {:ok, changeset} <- PasswordReset.change_token_data(token_data) do
      render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"token_data" => token_data_params}) do
    with {:ok, user} <- PasswordReset.generate_token(token_data_params),
         :ok = PasswordResetMailer.send(user) do
      email_sent_response(conn, Routes.page_path(conn, :index))
    else
      {:error, %Ecto.Changeset{} = changeset} -> render(conn, "new.html", changeset: changeset)
      {:error, _reason} -> email_sent_response(conn, Routes.page_path(conn, :index))
    end
  end

  def create(conn, %{"user_id" => user_id, "church_slug" => church_slug}) do
    with {:ok, user} <- PasswordReset.generate_token(user_id, church_slug),
         :ok = PasswordResetMailer.send(user) do
      email_sent_response(conn, Routes.user_path(conn, :edit, user.church.slug, user))
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, error_message(reason))
        |> redirect(to: Routes.password_reset_path(conn, :new))
    end
  end

  defp email_sent_response(conn, path) do
    conn
    |> put_flash(
      :info,
      gettext("We sent you an email with the instructions to reset your password.")
    )
    |> redirect(to: path)
  end

  def edit(conn, %{"church_slug" => slug, "id" => token}) do
    with {:ok, user} <- PasswordReset.validate_token(token, slug),
         {:ok, credential} <- PasswordReset.find_credential(user),
         {:ok, changeset} <- PasswordReset.change_credential(credential) do
      render(conn, "edit.html", changeset: changeset)
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, error_message(reason))
        |> redirect(to: Routes.password_reset_path(conn, :new))
    end
  end

  def update(conn, %{"church_slug" => slug, "id" => token, "credential" => attrs}) do
    with {:ok, credential} <- PasswordReset.reset(token, attrs, slug) do
      conn
      |> Session.put_user(credential.user)
      |> put_flash(:info, gettext("Password reset succesfully."))
      |> redirect(to: Routes.dashboard_path(conn, :index, credential.church.slug))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp error_message(%Ecto.Changeset{errors: errors}), do: error_message(errors)

  defp error_message(:not_found) do
    gettext("The given password reset token does not refer to any user.")
  end

  defp error_message([{:password_reset_token, {_, [validation: :expired]}} | _]) do
    gettext("The given password reset token is invalid or expired, please request another email.")
  end

  defp error_message([_ | t]), do: error_message(t)
end
