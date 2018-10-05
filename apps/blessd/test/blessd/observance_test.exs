defmodule Blessd.ObservanceTest do
  use Blessd.DataCase

  alias Blessd.Observance

  describe "services" do
    alias Blessd.Observance.Service

    @valid_attrs %{date: ~D[2018-10-10]}
    @update_attrs %{date: ~D[2000-01-01]}
    @invalid_attrs %{date: nil}

    def service_fixture(attrs \\ %{}, church) do
      {:ok, service} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Observance.create_service(church)

      service
    end

    test "list_services/0 returns all services" do
      church = auth_church()
      service = service_fixture(church)
      assert [found] = Observance.list_services(church)

      assert found.date == service.date
    end

    test "get_service!/1 returns the service with given id" do
      church = auth_church()
      service = service_fixture(church)
      assert found = Observance.get_service!(service.id, church)

      assert found.date == service.date
    end

    test "create_service/1 with valid data creates a service" do
      church = auth_church()
      assert {:ok, %Service{} = service} = Observance.create_service(@valid_attrs, church)
      assert service.date == ~D[2018-10-10]
    end

    test "create_service/1 with invalid data returns error changeset" do
      church = auth_church()
      assert {:error, %Ecto.Changeset{}} = Observance.create_service(@invalid_attrs, church)
    end

    test "update_service/2 with valid data updates the service" do
      church = auth_church()
      service = service_fixture(church)
      assert {:ok, service} = Observance.update_service(service, @update_attrs, church)
      assert %Service{} = service
      assert service.date == ~D[2000-01-01]
    end

    test "update_service/2 with invalid data returns error changeset" do
      church = auth_church()
      service = service_fixture(church)

      assert {:error, %Ecto.Changeset{}} =
               Observance.update_service(service, @invalid_attrs, church)

      assert found = Observance.get_service!(service.id, church)

      assert found.date == service.date
    end

    test "delete_service/1 deletes the service" do
      church = auth_church()
      service = service_fixture(church)
      assert {:ok, %Service{}} = Observance.delete_service(service, church)
      assert_raise Ecto.NoResultsError, fn -> Observance.get_service!(service.id, church) end
    end

    test "change_service/1 returns a service changeset" do
      church = auth_church()
      service = service_fixture(church)
      assert %Ecto.Changeset{} = Observance.change_service(service, church)
    end
  end
end
