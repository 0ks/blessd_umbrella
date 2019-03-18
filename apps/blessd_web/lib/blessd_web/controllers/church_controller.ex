defmodule BlessdWeb.ChurchController do
  use BlessdWeb, :controller

  alias Blessd.Accounts

  def edit(conn, _params) do
    with current_user = conn.assigns.current_user,
         id = current_user.church.id,
         {:ok, changeset} <- Accounts.edit_church_changeset(id, current_user) do
      render(conn, "edit.html", changeset: changeset)
    end
  end

  def update(conn, %{"church" => church_params}) do
    with current_user = conn.assigns.current_user,
         id = current_user.church.id,
         {:ok, church} <- Accounts.update_church(id, church_params, current_user) do
      conn
      |> put_flash(:info, gettext("Church updated successfully."))
      |> redirect(to: Routes.church_path(conn, :edit, church.slug))
    else
      {:error, %Ecto.Changeset{} = changeset} -> render(conn, "edit.html", changeset: changeset)
      {:error, reason} -> {:error, reason}
    end
  end

  def delete(conn, _params) do
    with current_user = conn.assigns.current_user,
         id = current_user.church.id,
         {:ok, _church} = Accounts.delete_church(id, current_user) do
      conn
      |> put_flash(:info, gettext("Church deleted successfully."))
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
