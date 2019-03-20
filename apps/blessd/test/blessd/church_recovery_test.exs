defmodule Blessd.ChurchRecoveryTest do
  use Blessd.DataCase

  alias Blessd.ChurchRecovery
  alias Blessd.ChurchRecovery.Credentials.Credential
  alias Blessd.ChurchRecovery.Users.User

  test "new_user returns a new user changeset" do
    assert {:ok, %Ecto.Changeset{}} = ChurchRecovery.new_user()
  end

  test "generate_token generates a new church recovery token" do
    %{email: email, id: id} = signup()

    assert {:ok, %Credential{user_id: ^id}} = ChurchRecovery.generate_token(%{email: email})
  end

  test "list_users list the users by a given church recovery token" do
    %{email: email, id: id} = signup()

    assert {:ok, %Credential{token: token}} = ChurchRecovery.generate_token(%{email: email})
    assert {:ok, [%User{id: ^id}]} = ChurchRecovery.list_users(token)
  end

  test "recover deletes the credential for the token" do
    %{email: email, id: id} = signup()

    assert {:ok, %Credential{token: token}} = ChurchRecovery.generate_token(%{email: email})
    assert {:ok, [%User{id: ^id}]} = ChurchRecovery.list_users(token)
    assert {:ok, %Credential{user_id: ^id}} = ChurchRecovery.recover(token)
    assert {:error, :not_found} = ChurchRecovery.list_users(token)
  end
end
