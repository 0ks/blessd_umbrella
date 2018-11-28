defmodule BlessdWeb.CustomFieldController do
  use BlessdWeb, :controller

  alias Blessd.Custom

  def index(conn, _params) do
    with {:ok, fields} <- Custom.list_fields(conn.assigns.current_user) do
      render(conn, "index.html", fields: fields)
    end
  end

  def new(conn, _params) do
    with {:ok, changeset} <- Custom.new_field_changeset(conn.assigns.current_user),
         {:ok, fields} <- Custom.list_fields(conn.assigns.current_user) do
      render(conn, "new.html", changeset: changeset, fields: fields)
    end
  end

  def create(conn, %{"field" => field_params}) do
    current_user = conn.assigns.current_user

    with {:ok, field} <- Custom.create(field_params, current_user) do
      conn
      |> put_flash(:info, gettext("Field successfully created."))
      |> redirect(to: Routes.custom_field_path(conn, :edit, current_user.church.slug, field))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        with {:ok, fields} <- Custom.list_fields(current_user) do
          render(conn, "new.html", changeset: changeset, fields: fields)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
