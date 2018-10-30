defmodule BlessdWeb.UserController do
  use BlessdWeb, :controller

  alias Blessd.Accounts

  def index(conn, _params) do
    users = Accounts.list_users(conn.assigns.current_church)
    render(conn, "index.html", users: users)
  end

  def edit(conn, %{"id" => id}) do
    church = conn.assigns.current_church

    changeset =
      id
      |> Accounts.get_user!(church)
      |> Accounts.change_user(church)

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    church = conn.assigns.current_church
    user = Accounts.get_user!(id, church)

    case Accounts.update_user(user, user_params, church) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, gettext("User updated successfully."))
        |> redirect(to: user_path(conn, :index, church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    church = conn.assigns.current_church
    user = Accounts.get_user!(id, church)
    {:ok, _user} = Accounts.delete_user(user, church)

    conn
    |> put_flash(:info, gettext("User deleted successfully."))
    |> redirect(to: user_path(conn, :index, church.identifier))
  end
end
