defmodule Blessd.InvitationTest do
  use Blessd.DataCase

  alias Blessd.Invitation
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
    assert {:ok, %User{}} = Invitation.validate_token(token, user)
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
end
