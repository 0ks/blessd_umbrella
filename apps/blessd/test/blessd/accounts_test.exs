defmodule Blessd.AccountsTest do
  use Blessd.DataCase

  alias Blessd.Accounts

  describe "churches" do
    alias Blessd.Accounts.Churches.Church
    alias Blessd.Shared.Churches.Church, as: SharedChurch
    alias Blessd.Shared.Users.User, as: SharedUser

    @update_attrs %{name: "some updated name", slug: "some_updated_slug"}
    @invalid_attrs %{name: nil, slug: nil}

    test "update_church/2 with valid data updates the church" do
      %{church: church} = user = signup()

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, SharedChurch)}, SharedUser)

      church = convert_struct!(church, Church)
      assert {:ok, church} = Accounts.update_church(church.id, @update_attrs, current_user)
      assert %Church{} = church
      assert church.name == "some updated name"
      assert church.slug == "some_updated_slug"
    end

    test "update_church/2 with invalid data returns error changeset" do
      %{church: church} = user = signup()

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, SharedChurch)}, SharedUser)

      church = convert_struct!(church, Church)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_church(church.id, @invalid_attrs, current_user)

      assert {:ok, found} = Accounts.Churches.find(church.id, current_user)

      assert found.name == church.name
      assert found.slug == church.slug
    end

    test "delete_church/1 deletes the church" do
      %{church: church} = user = signup()

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, SharedChurch)}, SharedUser)

      church = convert_struct!(church, Church)
      assert {:ok, %Church{}} = Accounts.delete_church(church.id, current_user)
      assert {:error, :not_found} == Accounts.Churches.find(church.id, current_user)
    end

    test "edit_church_changeset/1 returns a church changeset" do
      %{church: church} = user = signup()

      current_user =
        convert_struct!(%{user | church: convert_struct!(church, SharedChurch)}, SharedUser)

      church = convert_struct!(church, Church)
      assert {:ok, %Ecto.Changeset{}} = Accounts.edit_church_changeset(church.id, current_user)
    end
  end

  describe "users" do
    alias Blessd.Accounts.Users.User
    alias Blessd.Shared.Users.User, as: SharedUser

    @update_attrs %{name: "some updated name", email: "some@updated.email"}
    @invalid_attrs %{name: nil, email: nil}

    test "list_users/0 returns all users" do
      user = signup()
      assert {:ok, [found]} = Accounts.list_users(user)
      assert found.name == user.name
    end

    test "update_user/2 with valid data updates the user" do
      user = signup()
      acc_user = convert_struct!(user, User)
      assert {:ok, %User{} = user} = Accounts.update_user(acc_user.id, @update_attrs, user)
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = signup()
      acc_user = convert_struct!(user, User)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(acc_user.id, @invalid_attrs, user)
      assert {:ok, found} = Accounts.Users.find(user.id, user)
      assert found.name == user.name
    end

    test "delete_user/1 deletes the user" do
      user = signup()
      acc_user = convert_struct!(user, User)
      assert {:ok, %User{}} = Accounts.delete_user(acc_user.id, user)
      assert {:error, :not_found} == Accounts.Users.find(acc_user.id, user)
    end

    test "edit_user_changeset/1 returns a changeset to change a user" do
      user = signup()
      acc_user = convert_struct!(user, User)
      assert {:ok, %Ecto.Changeset{}} = Accounts.edit_user_changeset(acc_user.id, user)
    end

    test "authorized_user?/3 returns if a given action is authorized" do
      user = signup()
      acc_user = convert_struct!(user, User)
      assert Accounts.authorized_user?(acc_user, :edit, user) == true
      assert Accounts.authorized_user?(User, :list, user) == true
      assert Accounts.authorized_user?(%User{}, :list, user) == false
    end

    test "invitation_pending? returns if the users has an inviation pending" do
      assert User.invitation_pending?(%User{invitation_token: nil}) == false
      assert User.invitation_pending?(%User{invitation_token: "blablabla"}) == true
    end

    test "invitation_expired? returns if the users has an inviation expired" do
      assert User.invitation_expired?(%User{invitation_token: nil}) == false

      assert User.invitation_expired?(%User{invitation_token: SharedUser.generate_token(60)}) ==
               false

      assert User.invitation_expired?(%User{invitation_token: SharedUser.generate_token(-1)}) ==
               true
    end
  end
end
