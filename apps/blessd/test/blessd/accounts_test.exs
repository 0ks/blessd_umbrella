defmodule Blessd.AccountsTest do
  use Blessd.DataCase

  alias Blessd.Accounts

  describe "churches" do
    alias Blessd.Accounts.Church
    alias Blessd.Auth.Church, as: AuthChurch
    alias Blessd.Auth.User, as: AuthUser

    @update_attrs %{name: "some updated name", identifier: "some_updated_identifier"}
    @invalid_attrs %{name: nil, identifier: nil}

    test "get_church!/1 returns the church with given id" do
      %{church: church} = user = signup(true)

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, AuthChurch)}, AuthUser)

      church = convert_struct!(church, Church)
      assert found = Accounts.get_church!(church.id, current_user)

      assert found.name == church.name
      assert found.identifier == church.identifier

      assert found = Accounts.get_church!(church.identifier, current_user)

      assert found.name == church.name
      assert found.identifier == church.identifier
    end

    test "update_church/2 with valid data updates the church" do
      %{church: church} = user = signup(true)

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, AuthChurch)}, AuthUser)

      church = convert_struct!(church, Church)
      assert {:ok, church} = Accounts.update_church(church, @update_attrs, current_user)
      assert %Church{} = church
      assert church.name == "some updated name"
      assert church.identifier == "some_updated_identifier"
    end

    test "update_church/2 with invalid data returns error changeset" do
      %{church: church} = user = signup(true)

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, AuthChurch)}, AuthUser)

      church = convert_struct!(church, Church)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_church(church, @invalid_attrs, current_user)

      assert found = Accounts.get_church!(church.id, current_user)

      assert found.name == church.name
      assert found.identifier == church.identifier
    end

    test "delete_church/1 deletes the church" do
      %{church: church} = user = signup(true)

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, AuthChurch)}, AuthUser)

      church = convert_struct!(church, Church)
      assert {:ok, %Church{}} = Accounts.delete_church(church, current_user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_church!(church.id, current_user) end
    end

    test "change_church/1 returns a church changeset" do
      %{church: church} = user = signup(true)

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, AuthChurch)}, AuthUser)

      church = convert_struct!(church, Church)
      assert %Ecto.Changeset{} = Accounts.change_church(church, current_user)
    end
  end
end
