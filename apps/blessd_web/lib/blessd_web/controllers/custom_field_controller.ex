defmodule BlessdWeb.CustomFieldController do
  use BlessdWeb, :controller

  alias Blessd.Custom

  def index(conn, %{"resource" => resource}) do
    with {:ok, fields} <- Custom.list_fields(resource, conn.assigns.current_user) do
      render(conn, "index.html", fields: fields)
    end
  end

  def new(conn, %{"resource" => resource}) do
    with {:ok, changeset} <- Custom.new_field_changeset(resource, conn.assigns.current_user),
         {:ok, fields} <- Custom.list_fields(resource, conn.assigns.current_user) do
      render(conn, "new.html", changeset: changeset, fields: fields)
    end
  end

  def create(conn, %{"resource" => resource, "field" => field_params}) do
    current_user = conn.assigns.current_user

    with {:ok, field} <- Custom.create_field(resource, field_params, current_user) do
      conn
      |> put_flash(:info, gettext("Field successfully created."))
      |> redirect(
        to: Routes.custom_field_path(conn, :edit, current_user.church.slug, field.resource, field)
      )
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        with {:ok, fields} <- Custom.list_fields(resource, current_user) do
          render(conn, "new.html", changeset: changeset, fields: fields)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, changeset} <- Custom.edit_field_changeset(id, conn.assigns.current_user),
         {:ok, fields} <- Custom.list_fields(changeset.data.resource, conn.assigns.current_user) do
      render(conn, "edit.html", changeset: changeset, fields: fields)
    end
  end

  def update(conn, %{"id" => id, "field" => field_params}) do
    current_user = conn.assigns.current_user

    with {:ok, field} <- Custom.update_field(id, field_params, current_user) do
      conn
      |> put_flash(:info, gettext("Field successfully updated."))
      |> redirect(
        to: Routes.custom_field_path(conn, :edit, current_user.church.slug, field.resource, field)
      )
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        with {:ok, fields} <- Custom.list_fields(changeset.data.resource, current_user) do
          render(conn, "edit.html", changeset: changeset, fields: fields)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user

    with {:ok, field} <- Custom.delete_field(id, current_user) do
      conn
      |> put_flash(:info, gettext("Field successfully deleted."))
      |> redirect(
        to: Routes.custom_field_path(conn, :index, current_user.church.slug, field.resource)
      )
    end
  end
end
