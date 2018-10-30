defmodule Blessd.AccountsTest do
  use Blessd.DataCase

  alias Blessd.Accounts

  describe "churches" do
    alias Blessd.Accounts.Church

    @update_attrs %{name: "some updated name", identifier: "some_updated_identifier"}
    @invalid_attrs %{name: nil, identifier: nil}

    defp get_church(%{church: church}) do
      church_map =
        church
        |> Map.from_struct()
        |> Map.take(Map.keys(%Church{}))

      struct!(Church, church_map)
    end

    test "get_church!/1 returns the church with given id" do
      church = get_church(signup())
      assert found = Accounts.get_church!(church.id)

      assert found.name == church.name
      assert found.identifier == church.identifier

      assert found = Accounts.get_church!(church.identifier)

      assert found.name == church.name
      assert found.identifier == church.identifier
    end

    test "update_church/2 with valid data updates the church" do
      church = get_church(signup())
      assert {:ok, church} = Accounts.update_church(church, @update_attrs)
      assert %Church{} = church
      assert church.name == "some updated name"
      assert church.identifier == "some_updated_identifier"
    end

    test "update_church/2 with invalid data returns error changeset" do
      church = get_church(signup())
      assert {:error, %Ecto.Changeset{}} = Accounts.update_church(church, @invalid_attrs)
      assert found = Accounts.get_church!(church.id)

      assert found.name == church.name
      assert found.identifier == church.identifier
    end

    test "delete_church/1 deletes the church" do
      church = get_church(signup())
      assert {:ok, %Church{}} = Accounts.delete_church(church)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_church!(church.id) end
    end

    test "change_church/1 returns a church changeset" do
      church = get_church(signup())
      assert %Ecto.Changeset{} = Accounts.change_church(church)
    end
  end
end
