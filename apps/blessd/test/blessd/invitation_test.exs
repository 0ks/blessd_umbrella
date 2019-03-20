defmodule Blessd.InvitationTest do
  use Blessd.DataCase

  alias Blessd.Invitation
  alias Blessd.Invitation.Accept
  alias Blessd.Invitation.User

  test "invite/2 invites a new user" do
    user = signup()
    assert {:ok, invited} = Invitation.invite(%{email: "john@mail.com"}, user)
    assert invited.email == "john@mail.com"
  end

  test "reinvite/2 reinvites an existing invited user" do
    user = signup()

    assert {:ok, %{id: id, invitation_token: token}} =
             Invitation.invite(%{email: "john@mail.com"}, user)

    assert {:ok, %{id: ^id}} = Invitation.reinvite(token, user)
  end

  test "validate_token/2 validates a given token" do
    user = signup()
    assert {:ok, %{invitation_token: token}} = Invitation.invite(%{email: "john@mail.com"}, user)
    assert {:ok, %User{}} = Invitation.validate_token(token, user.church.slug)
  end

  test "accept/4 accepts an invitation" do
    user = signup()
    assert {:ok, %{invitation_token: token}} = Invitation.invite(%{email: "john@mail.com"}, user)

    assert {:ok, %User{}} =
             Invitation.accept(
               token,
               %{
                 "user" => %{"name" => "John"},
                 "credential" => %{"source" => "password", "token" => "password"}
               },
               user
             )
  end

  test "new_accept returns a new accept" do
    user = signup()
    assert {:ok, %Accept{}} = Invitation.new_accept(user)
  end

  test "change_user returns a changeset for a given user" do
    user = signup()
    {:ok, invite_user} = Invitation.new_user(user)
    assert {:ok, %Ecto.Changeset{}} = Invitation.change_user(invite_user, user)
  end

  test "change_credential returns a changeset for a given credential" do
    user = signup()
    {:ok, credential} = Invitation.new_credential(user)
    assert {:ok, %Ecto.Changeset{}} = Invitation.change_credential(credential, user)
  end

  test "authorized?/3 returns if a given action is authorized" do
    user = signup()
    invite_user = convert_struct!(user, User)
    assert Invitation.authorized?(invite_user, :change, user) == true
    assert Invitation.authorized?(User, :list, user) == true
    assert Invitation.authorized?(%User{}, :list, user) == false
  end
end
