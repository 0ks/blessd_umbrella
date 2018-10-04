defmodule BlessdWeb.ServiceController do
  use BlessdWeb, :controller

  alias Blessd.Observance
  alias Blessd.Observance.Service

  def index(conn, _params) do
    services = Observance.list_services()
    render(conn, "index.html", services: services)
  end

  def new(conn, _params) do
    changeset = Observance.change_service(%Service{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"service" => service_params}) do
    case Observance.create_service(service_params) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, "Service created successfully.")
        |> redirect(to: service_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    changeset =
      id
      |> Observance.get_service!()
      |> Observance.change_service()

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "service" => service_params}) do
    service = Observance.get_service!(id)

    case Observance.update_service(service, service_params) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, "Service updated successfully.")
        |> redirect(to: service_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    service = Observance.get_service!(id)
    {:ok, _service} = Observance.delete_service(service)

    conn
    |> put_flash(:info, "Service deleted successfully.")
    |> redirect(to: service_path(conn, :index))
  end
end
