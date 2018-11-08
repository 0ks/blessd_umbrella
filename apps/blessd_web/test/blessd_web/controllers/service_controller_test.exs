defmodule BlessdWeb.ServiceControllerTest do
  use BlessdWeb.ConnCase

  alias Blessd.Observance

  @create_attrs %{date: ~D[2018-10-10]}
  @update_attrs %{date: ~D[2000-01-01]}
  @invalid_attrs %{date: nil}

  def fixture(:service, user) do
    {:ok, service} = Observance.create_service(@create_attrs, user)
    service
  end

  describe "index" do
    test "lists all services", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.service_path(conn, :index, user.church.identifier))

      assert html_response(conn, 200) =~ "Listing Services"
    end
  end

  describe "new service" do
    test "renders form", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.service_path(conn, :new, user.church.identifier))

      assert html_response(conn, 200) =~ "New Service"
    end
  end

  describe "create service" do
    test "redirects to index when data is valid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.service_path(conn, :create, user.church.identifier), service: @create_attrs)

      assert redirected_to(conn) == Routes.service_path(conn, :index, user.church.identifier)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.service_path(conn, :create, user.church.identifier), service: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Service"
    end
  end

  describe "edit service" do
    test "renders form for editing chosen service", %{conn: conn} do
      user = signup()
      service = fixture(:service, user)

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.service_path(conn, :edit, user.church.identifier, service))

      assert html_response(conn, 200) =~ "Edit Service"
    end
  end

  describe "update service" do
    test "redirects when data is valid", %{conn: conn} do
      user = signup()
      service = fixture(:service, user)

      resp =
        conn
        |> authenticate(user)
        |> put(Routes.service_path(conn, :update, user.church.identifier, service),
          service: @update_attrs
        )

      assert redirected_to(resp) == Routes.service_path(conn, :index, user.church.identifier)

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.service_path(conn, :index, user.church.identifier))

      assert html_response(resp, 200) =~ "01/01/2000"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()
      service = fixture(:service, user)

      conn =
        conn
        |> authenticate(user)
        |> put(Routes.service_path(conn, :update, user.church.identifier, service),
          service: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Service"
    end
  end

  describe "delete service" do
    test "deletes chosen service", %{conn: conn} do
      user = signup()
      service = fixture(:service, user)

      resp =
        conn
        |> authenticate(user)
        |> delete(Routes.service_path(conn, :delete, user.church.identifier, service))

      assert redirected_to(resp) == Routes.service_path(conn, :index, user.church.identifier)

      assert_error_sent(404, fn ->
        conn
        |> authenticate(user)
        |> get(Routes.service_path(conn, :edit, user.church.identifier, service))
      end)
    end
  end
end
