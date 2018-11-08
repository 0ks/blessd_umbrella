defmodule Blessd.ObservanceTest do
  use Blessd.DataCase

  alias Blessd.Observance

  describe "services" do
    alias Blessd.Observance.Service

    @valid_attrs %{date: ~D[2018-10-10]}
    @update_attrs %{date: ~D[2000-01-01]}
    @invalid_attrs %{date: nil}

    def service_fixture(attrs \\ %{}, user) do
      {:ok, service} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Observance.create_service(user)

      service
    end

    test "list_services/0 returns all services" do
      user = signup()
      service = service_fixture(user)
      assert [found] = Observance.list_services(user)

      assert found.date == service.date
    end

    test "get_service!/1 returns the service with given id" do
      user = signup()
      service = service_fixture(user)
      assert found = Observance.get_service!(service.id, user)

      assert found.date == service.date
    end

    test "create_service/1 with valid data creates a service" do
      user = signup()
      assert {:ok, %Service{} = service} = Observance.create_service(@valid_attrs, user)
      assert service.date == ~D[2018-10-10]
    end

    test "create_service/1 with invalid data returns error changeset" do
      user = signup()
      assert {:error, %Ecto.Changeset{}} = Observance.create_service(@invalid_attrs, user)
    end

    test "update_service/2 with valid data updates the service" do
      user = signup()
      service = service_fixture(user)
      assert {:ok, service} = Observance.update_service(service, @update_attrs, user)
      assert %Service{} = service
      assert service.date == ~D[2000-01-01]
    end

    test "update_service/2 with invalid data returns error changeset" do
      user = signup()
      service = service_fixture(user)

      assert {:error, %Ecto.Changeset{}} =
               Observance.update_service(service, @invalid_attrs, user)

      assert found = Observance.get_service!(service.id, user)

      assert found.date == service.date
    end

    test "delete_service/1 deletes the service" do
      user = signup()
      service = service_fixture(user)
      assert {:ok, %Service{}} = Observance.delete_service(service, user)
      assert_raise Ecto.NoResultsError, fn -> Observance.get_service!(service.id, user) end
    end

    test "change_service/1 returns a service changeset" do
      user = signup()
      service = service_fixture(user)
      assert %Ecto.Changeset{} = Observance.change_service(service, user)
    end
  end
end
