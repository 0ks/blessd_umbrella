defmodule Blessd.AccountsTest do
  use Blessd.DataCase

  alias Blessd.Accounts

  describe "churches" do
    alias Blessd.Accounts.Church

    @valid_attrs %{name: "some name", identifier: "some_identifier"}
    @update_attrs %{name: "some updated name", identifier: "some_updated_identifier"}
    @invalid_attrs %{name: nil, identifier: nil}

    def church_fixture(attrs \\ %{}) do
      {:ok, church} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_church()

      church
    end

    test "get_church!/1 returns the church with given id" do
      church = church_fixture()
      assert found = Accounts.get_church!(church.id)

      assert found.name == church.name
      assert found.identifier == church.identifier

      assert found = Accounts.get_church!(church.identifier)

      assert found.name == church.name
      assert found.identifier == church.identifier
    end

    test "create_church/1 with valid data creates a church" do
      assert {:ok, %Church{} = church} = Accounts.create_church(@valid_attrs)
      assert church.name == "some name"
      assert church.identifier == "some_identifier"
    end

    test "create_church/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_church(@invalid_attrs)
    end

    test "update_church/2 with valid data updates the church" do
      church = church_fixture()
      assert {:ok, church} = Accounts.update_church(church, @update_attrs)
      assert %Church{} = church
      assert church.name == "some updated name"
      assert church.identifier == "some_updated_identifier"
    end

    test "update_church/2 with invalid data returns error changeset" do
      church = church_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_church(church, @invalid_attrs)
      assert found = Accounts.get_church!(church.id)

      assert found.name == church.name
      assert found.identifier == church.identifier
    end

    test "delete_church/1 deletes the church" do
      church = church_fixture()
      assert {:ok, %Church{}} = Accounts.delete_church(church)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_church!(church.id) end
    end

    test "change_church/1 returns a church changeset" do
      church = church_fixture()
      assert %Ecto.Changeset{} = Accounts.change_church(church)
    end
  end
end
