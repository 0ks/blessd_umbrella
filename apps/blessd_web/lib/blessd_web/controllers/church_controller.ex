defmodule BlessdWeb.ChurchController do
  use BlessdWeb, :controller

  alias Blessd.Accounts

  def edit(conn, _params) do
    current_user = conn.assigns.current_user

    changeset =
      current_user.church.id
      |> Accounts.get_church!(current_user)
      |> Accounts.change_church(current_user)

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"church" => church_params}) do
    current_user = conn.assigns.current_user

    current_user.church_id
    |> Accounts.get_church!(current_user)
    |> Accounts.update_church(church_params, current_user)
    |> case do
      {:ok, church} ->
        conn
        |> put_flash(:info, gettext("Church updated successfully."))
        |> redirect(to: Routes.church_path(conn, :edit, church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    current_user = conn.assigns.current_user

    {:ok, _church} =
      current_user.church.id
      |> Accounts.get_church!(current_user)
      |> Accounts.delete_church(current_user)

    conn
    |> put_flash(:info, gettext("Church deleted successfully."))
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
