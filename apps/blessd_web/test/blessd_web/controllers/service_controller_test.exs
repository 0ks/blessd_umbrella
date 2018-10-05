defmodule BlessdWeb.ServiceControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Observance

  @create_attrs %{date: ~D[2018-10-10]}
  @update_attrs %{date: ~D[2000-01-01]}
  @invalid_attrs %{date: nil}

  def fixture(:service, church) do
    {:ok, service} = Observance.create_service(@create_attrs, church)
    service
  end

  describe "index" do
    test "lists all services", %{conn: conn} do
      church = auth_church()
      conn = get(conn, service_path(conn, :index, church))
      assert html_response(conn, 200) =~ "Listing Services"
    end
  end

  describe "new service" do
    test "renders form", %{conn: conn} do
      church = auth_church()
      conn = get(conn, service_path(conn, :new, church))
      assert html_response(conn, 200) =~ "New Service"
    end
  end

  describe "create service" do
    test "redirects to index when data is valid", %{conn: conn} do
      church = auth_church()
      conn = post(conn, service_path(conn, :create, church), service: @create_attrs)
      assert redirected_to(conn) == service_path(conn, :index, church)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      church = auth_church()
      conn = post(conn, service_path(conn, :create, church), service: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Service"
    end
  end

  describe "edit service" do
    test "renders form for editing chosen service", %{conn: conn} do
      church = auth_church()
      service = fixture(:service, church)
      conn = get(conn, service_path(conn, :edit, church, service))
      assert html_response(conn, 200) =~ "Edit Service"
    end
  end

  describe "update service" do
    test "redirects when data is valid", %{conn: conn} do
      church = auth_church()
      service = fixture(:service, church)
      conn = put(conn, service_path(conn, :update, church, service), service: @update_attrs)
      assert redirected_to(conn) == service_path(conn, :index, church)

      conn = get(conn, service_path(conn, :index, church))
      assert html_response(conn, 200) =~ "01/01/2000"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      church = auth_church()
      service = fixture(:service, church)
      conn = put(conn, service_path(conn, :update, church, service), service: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Service"
    end
  end

  describe "delete service" do
    test "deletes chosen service", %{conn: conn} do
      church = auth_church()
      service = fixture(:service, church)

      conn = delete(conn, service_path(conn, :delete, church, service))
      assert redirected_to(conn) == service_path(conn, :index, church)

      assert_error_sent(404, fn ->
        get(conn, service_path(conn, :edit, church, service))
      end)
    end
  end
end
