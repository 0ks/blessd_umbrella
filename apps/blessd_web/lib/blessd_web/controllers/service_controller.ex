defmodule BlessdWeb.ServiceController do
  use BlessdWeb, :controller

  alias Blessd.Observance

  def index(conn, _params) do
    services = Observance.list_services(conn.assigns.current_church)
    render(conn, "index.html", services: services)
  end

  def new(conn, _params) do
    church = conn.assigns.current_church

    changeset =
      church
      |> Observance.new_service()
      |> Observance.change_service(church)

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"service" => service_params}) do
    church = conn.assigns.current_church

    case Observance.create_service(service_params, church) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, gettext("Service created successfully."))
        |> redirect(to: service_path(conn, :index, church))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    church = conn.assigns.current_church

    changeset =
      id
      |> Observance.get_service!(church)
      |> Observance.change_service(church)

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "service" => service_params}) do
    church = conn.assigns.current_church
    service = Observance.get_service!(id, church)

    case Observance.update_service(service, service_params, church) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, gettext("Service updated successfully."))
        |> redirect(to: service_path(conn, :index, church))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    church = conn.assigns.current_church
    service = Observance.get_service!(id, church)
    {:ok, _service} = Observance.delete_service(service, church)

    conn
    |> put_flash(:info, gettext("Service deleted successfully."))
    |> redirect(to: service_path(conn, :index, church))
  end
end
