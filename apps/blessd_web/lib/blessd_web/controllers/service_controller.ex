defmodule BlessdWeb.ServiceController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, _params) do
    services = Observance.list_services(conn.assigns.current_user)
    render(conn, "index.html", services: services)
  end

  def new(conn, _params) do
    user = conn.assigns.current_user

    changeset =
      user
      |> Observance.new_service()
      |> Observance.change_service(user)

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"service" => service_params}) do
    user = conn.assigns.current_user

    case Observance.create_service(service_params, user) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, gettext("Service created successfully."))
        |> redirect(to: service_path(conn, :index, user.church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    changeset =
      id
      |> Observance.get_service!(user)
      |> Observance.change_service(user)

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "service" => service_params}) do
    user = conn.assigns.current_user
    service = Observance.get_service!(id, user)

    case Observance.update_service(service, service_params, user) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, gettext("Service updated successfully."))
        |> redirect(to: service_path(conn, :index, user.church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    service = Observance.get_service!(id, user)
    {:ok, _service} = Observance.delete_service(service, user)

    conn
    |> put_flash(:info, gettext("Service deleted successfully."))
    |> redirect(to: service_path(conn, :index, user.church.identifier))
  end
end
