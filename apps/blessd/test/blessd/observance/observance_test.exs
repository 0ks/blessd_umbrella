defmodule Blessd.ObservanceTest do
  use Blessd.DataCase

  alias Blessd.Observance

  describe "services" do
    alias Blessd.Observance.Service

    @valid_attrs %{name: "some name", date: ~D[2018-10-10]}
    @update_attrs %{name: "some updated name", date: ~D[2000-01-01]}
    @invalid_attrs %{name: nil, date: nil}

    def service_fixture(attrs \\ %{}) do
      {:ok, service} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Observance.create_service()

      service
    end

    test "list_services/0 returns all services" do
      service = service_fixture()
      assert [found] = Observance.list_services()

      assert found.name == service.name
      assert found.date == service.date
    end

    test "get_service!/1 returns the service with given id" do
      service = service_fixture()
      assert found = Observance.get_service!(service.id)

      assert found.name == service.name
      assert found.date == service.date
    end

    test "create_service/1 with valid data creates a service" do
      assert {:ok, %Service{} = service} = Observance.create_service(@valid_attrs)
      assert service.name == "some name"
      assert service.date == ~D[2018-10-10]
    end

    test "create_service/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Observance.create_service(@invalid_attrs)
    end

    test "update_service/2 with valid data updates the service" do
      service = service_fixture()
      assert {:ok, service} = Observance.update_service(service, @update_attrs)
      assert %Service{} = service
      assert service.name == "some updated name"
      assert service.date == ~D[2000-01-01]
    end

    test "update_service/2 with invalid data returns error changeset" do
      service = service_fixture()
      assert {:error, %Ecto.Changeset{}} = Observance.update_service(service, @invalid_attrs)
      assert found = Observance.get_service!(service.id)

      assert found.name == service.name
      assert found.date == service.date
    end

    test "delete_service/1 deletes the service" do
      service = service_fixture()
      assert {:ok, %Service{}} = Observance.delete_service(service)
      assert_raise Ecto.NoResultsError, fn -> Observance.get_service!(service.id) end
    end

    test "change_service/1 returns a service changeset" do
      service = service_fixture()
      assert %Ecto.Changeset{} = Observance.change_service(service)
    end
  end
end