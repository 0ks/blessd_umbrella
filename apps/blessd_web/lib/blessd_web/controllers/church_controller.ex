defmodule BlessdWeb.ChurchController do
  use BlessdWeb, :controller

  alias Blessd.Accounts
  alias Blessd.Accounts.Church

  def new(conn, _params) do
    changeset = Accounts.change_church(%Church{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"church" => church_params}) do
    case Accounts.create_church(church_params) do
      {:ok, church} ->
        conn
        |> put_flash(:info, gettext("Church created successfully."))
        |> redirect(to: person_path(conn, :index, church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    changeset =
      conn.assigns.current_church.id
      |> Accounts.get_church!()
      |> Accounts.change_church()

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"church" => church_params}) do
    conn.assigns.current_church.id
    |> Accounts.get_church!()
    |> Accounts.update_church(church_params)
    |> case do
      {:ok, church} ->
        conn
        |> put_flash(:info, gettext("Church updated successfully."))
        |> redirect(to: person_path(conn, :index, church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    {:ok, _church} =
      conn.assigns.current_church.id
      |> Accounts.get_church!()
      |> Accounts.delete_church()

    conn
    |> put_flash(:info, gettext("Church deleted successfully."))
    |> redirect(to: page_path(conn, :index))
  end
end