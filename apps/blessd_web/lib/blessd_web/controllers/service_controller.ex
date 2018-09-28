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
    attendants = Observance.list_attendants()
    render(conn, "new.html", changeset: changeset, attendants: attendants)
  end

  defp attendant_ids_from_param(params) do
    params
    |> Map.get("attendants", [])
    |> Stream.filter(&(elem(&1, 1) == "on"))
    |> Stream.map(&elem(&1, 0))
    |> Enum.map(&String.to_integer/1)
  end

  def create(conn, %{"service" => service_params} = params) do
    attendant_ids = attendant_ids_from_param(params)

    case Observance.create_service(service_params, attendant_ids) do
      {:ok, %{service: service}} ->
        conn
        |> put_flash(:info, "Service created successfully.")
        |> redirect(to: service_path(conn, :edit, service))

      {:error, %{service: %Ecto.Changeset{} = changeset, attendants: attendants}} ->
        render(conn, "new.html", changeset: changeset, attendants: attendants)
    end
  end

  def edit(conn, %{"id" => id}) do
    service = Observance.get_service!(id)
    changeset = Observance.change_service(service)
    attendants = Observance.list_attendants(service)
    render(conn, "edit.html", changeset: changeset, attendants: attendants)
  end

  def update(conn, %{"id" => id, "service" => service_params} = params) do
    service = Observance.get_service!(id)
    attendant_ids = attendant_ids_from_param(params)

    case Observance.update_service(service, service_params, attendant_ids) do
      {:ok, %{service: service}} ->
        conn
        |> put_flash(:info, "Service updated successfully.")
        |> redirect(to: service_path(conn, :edit, service))

      {:error, %{service: %Ecto.Changeset{} = changeset, attendants: attendants}} ->
        render(conn, "edit.html", changeset: changeset, attendants: attendants)
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
