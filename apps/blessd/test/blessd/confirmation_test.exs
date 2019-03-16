defmodule Blessd.ConfirmationTest do
  use Blessd.DataCase

  alias Blessd.Signup
  alias Blessd.Confirmation
  alias Blessd.Confirmation.User

  @signup_attrs %{
    "church" => %{name: "Test Church", slug: "test_church"},
    "user" => %{name: "Test User", email: "test_user@mail.com"},
    "credential" => %{source: "password", token: "password"}
  }

  test "confirm confirms the user of the given token" do
    {:ok, user} = Signup.register(@signup_attrs)
    assert user.confirmed_at == nil
    assert user.confirmation_token != nil

    assert {:ok, %User{} = user} = Confirmation.confirm(user.confirmation_token, user.church.slug)
    assert user.confirmed_at != nil
    assert user.confirmation_token == nil
  end
end
