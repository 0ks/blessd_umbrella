defmodule BlessdWeb.ServiceControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Observance

  @create_attrs %{date: ~D[2018-10-10]}
  @update_attrs %{date: ~D[2000-01-01]}
  @invalid_attrs %{date: nil}

  def fixture(:service) do
    {:ok, service} = Observance.create_service(@create_attrs)
    service
  end

  describe "index" do
    test "lists all services", %{conn: conn} do
      conn = get(conn, service_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Services"
    end
  end

  describe "new service" do
    test "renders form", %{conn: conn} do
      conn = get(conn, service_path(conn, :new))
      assert html_response(conn, 200) =~ "New Service"
    end
  end

  describe "create service" do
    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, service_path(conn, :create), service: @create_attrs)
      assert redirected_to(conn) == service_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, service_path(conn, :create), service: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Service"
    end
  end

  describe "edit service" do
    setup [:create_service]

    test "renders form for editing chosen service", %{conn: conn, service: service} do
      conn = get(conn, service_path(conn, :edit, service))
      assert html_response(conn, 200) =~ "Edit Service"
    end
  end

  describe "update service" do
    setup [:create_service]

    test "redirects when data is valid", %{conn: conn, service: service} do
      conn = put(conn, service_path(conn, :update, service), service: @update_attrs)
      assert redirected_to(conn) == service_path(conn, :index)

      conn = get(conn, service_path(conn, :index))
      assert html_response(conn, 200) =~ "01/01/2000"
    end

    test "renders errors when data is invalid", %{conn: conn, service: service} do
      conn = put(conn, service_path(conn, :update, service), service: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Service"
    end
  end

  describe "delete service" do
    setup [:create_service]

    test "deletes chosen service", %{conn: conn, service: service} do
      conn = delete(conn, service_path(conn, :delete, service))
      assert redirected_to(conn) == service_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, service_path(conn, :edit, service))
      end)
    end
  end

  defp create_service(_) do
    service = fixture(:service)
    {:ok, service: service}
  end
end
