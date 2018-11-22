defmodule Blessd.AccountsTest do
  use Blessd.DataCase

  alias Blessd.Accounts

  describe "churches" do
    alias Blessd.Accounts.Church
    alias Blessd.Auth.Church, as: AuthChurch
    alias Blessd.Auth.User, as: AuthUser

    @update_attrs %{name: "some updated name", slug: "some_updated_slug"}
    @invalid_attrs %{name: nil, slug: nil}

    test "find_church/1 returns the church with given id" do
      %{church: church} = user = signup()

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, AuthChurch)}, AuthUser)

      church = convert_struct!(church, Church)
      assert {:ok, found} = Accounts.find_church(church.id, current_user)

      assert found.name == church.name
      assert found.slug == church.slug

      assert {:ok, found} = Accounts.find_church(church.slug, current_user)

      assert found.name == church.name
      assert found.slug == church.slug
    end

    test "update_church/2 with valid data updates the church" do
      %{church: church} = user = signup()

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, AuthChurch)}, AuthUser)

      church = convert_struct!(church, Church)
      assert {:ok, church} = Accounts.update_church(church, @update_attrs, current_user)
      assert %Church{} = church
      assert church.name == "some updated name"
      assert church.slug == "some_updated_slug"
    end

    test "update_church/2 with invalid data returns error changeset" do
      %{church: church} = user = signup()

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, AuthChurch)}, AuthUser)

      church = convert_struct!(church, Church)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_church(church, @invalid_attrs, current_user)

      assert {:ok, found} = Accounts.find_church(church.id, current_user)

      assert found.name == church.name
      assert found.slug == church.slug
    end

    test "delete_church/1 deletes the church" do
      %{church: church} = user = signup()

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, AuthChurch)}, AuthUser)

      church = convert_struct!(church, Church)
      assert {:ok, %Church{}} = Accounts.delete_church(church, current_user)
      assert {:error, :not_found} == Accounts.find_church(church.id, current_user)
    end

    test "change_church/1 returns a church changeset" do
      %{church: church} = user = signup()

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, AuthChurch)}, AuthUser)

      church = convert_struct!(church, Church)
      assert {:ok, %Ecto.Changeset{}} = Accounts.change_church(church, current_user)
    end
  end
end
