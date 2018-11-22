defmodule BlessdWeb.ChurchController do
  use BlessdWeb, :controller

  alias Blessd.Accounts

  def edit(conn, _params) do
    with current_user = conn.assigns.current_user,
         {:ok, church} <- Accounts.find_church(current_user.church.id, current_user),
         {:ok, changeset} <- Accounts.change_church(church, current_user) do
      render(conn, "edit.html", changeset: changeset)
    end
  end

  def update(conn, %{"church" => church_params}) do
    with current_user = conn.assigns.current_user,
         {:ok, church} <- Accounts.find_church(current_user.church_id, current_user),
         {:ok, church} <- Accounts.update_church(church, church_params, current_user) do
      conn
      |> put_flash(:info, gettext("Church updated successfully."))
      |> redirect(to: Routes.church_path(conn, :edit, church))
    else
      {:error, %Ecto.Changeset{} = changeset} -> render(conn, "edit.html", changeset: changeset)
      {:error, reason} -> {:error, reason}
    end
  end

  def delete(conn, _params) do
    with current_user = conn.assigns.current_user,
         {:ok, church} <- Accounts.find_church(current_user.church.id, current_user),
         {:ok, _church} = Accounts.delete_church(church, current_user) do
      conn
      |> put_flash(:info, gettext("Church deleted successfully."))
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
