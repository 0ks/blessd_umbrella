defmodule BlessdWeb.ChurchRecoveryController do
  use BlessdWeb, :controller

  alias Blessd.Auth
  alias Blessd.ChurchRecovery
  alias BlessdWeb.ChurchRecoveryMailer
  alias BlessdWeb.Session

  def new(conn, _params) do
    with {:ok, changeset} <- ChurchRecovery.new_user() do
      render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, credential} <- ChurchRecovery.generate_token(user_params),
         :ok <- ChurchRecoveryMailer.send(credential) do
      email_sent_response(conn, Routes.page_path(conn, :index))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)

      {:error, _} ->
        email_sent_response(conn, Routes.page_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => token}) do
    with {:ok, users} <- ChurchRecovery.list_users(token) do
      render(conn, "edit.html", users: users, token: token)
    end
  end

  def update(conn, %{"id" => token, "user_id" => user_id, "church_id" => church_id}) do
    with {:ok, _credential} <- ChurchRecovery.recover(token),
         {:ok, user} <- Auth.find_user(user_id, church_id) do
      conn
      |> Session.put_user(user)
      |> put_flash(:info, "Church recovered successfully.")
      |> redirect(to: Routes.dashboard_path(conn, :index, user.church.slug))
    end
  end

  defp email_sent_response(conn, path) do
    conn
    |> put_flash(
      :info,
      gettext("We sent you an email with the instructions to recover your church.")
    )
    |> redirect(to: path)
  end
end
