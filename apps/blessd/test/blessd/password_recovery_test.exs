defmodule Blessd.PasswordResetTest do
  use Blessd.DataCase

  alias Blessd.PasswordReset
  alias Blessd.PasswordReset.Credential
  alias Blessd.PasswordReset.User

  test "generate_token generates a new password reset token" do
    %{church: church, id: id, email: email} = signup()
    assert {:ok, %User{} = user} = PasswordReset.generate_token(id, church.slug)
    assert user.id == id
    assert user.password_reset_token != nil

    assert {:ok, %User{} = user} =
             PasswordReset.generate_token(%{church_slug: church.slug, email: email})

    assert user.id == id
    assert user.password_reset_token != nil
  end

  test "validate_token validates the given token" do
    %{church: church, id: id} = signup()

    assert {:ok, %User{password_reset_token: token}} =
             PasswordReset.generate_token(id, church.slug)

    assert {:ok, %User{}} = PasswordReset.validate_token(token, church.slug)
  end

  test "reset resets the password" do
    %{church: church, id: id} = signup()

    assert {:ok, %User{password_reset_token: token}} =
             PasswordReset.generate_token(id, church.slug)

    assert {:ok, %Credential{}} =
             PasswordReset.reset(token, %{source: "password", token: "password"}, church.slug)
  end
end
