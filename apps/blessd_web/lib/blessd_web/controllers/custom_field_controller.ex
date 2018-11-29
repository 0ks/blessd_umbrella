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

    with {:ok, field} <- Custom.create_field(field_params, current_user) do
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

  def edit(conn, %{"id" => id}) do
    with {:ok, changeset} <- Custom.edit_field_changeset(id, conn.assigns.current_user),
         {:ok, fields} <- Custom.list_fields(conn.assigns.current_user) do
      render(conn, "edit.html", changeset: changeset, fields: fields)
    end
  end

  def update(conn, %{"id" => id, "field" => field_params}) do
    current_user = conn.assigns.current_user

    with {:ok, field} <- Custom.update_field(id, field_params, current_user) do
      conn
      |> put_flash(:info, gettext("Field successfully updated."))
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

  def delete(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user

    with {:ok, _field} <- Custom.delete_field(id, current_user) do
      conn
      |> put_flash(:info, gettext("Field successfully deleted."))
      |> redirect(to: Routes.custom_field_path(conn, :index, current_user.church.slug))
    end
  end
end
