defmodule Blessd.AuthenticationTest do
  use Blessd.DataCase

  alias Blessd.Authentication

  test "authenticate/2 authenticates a user by its email and password" do
    %{church: church, user: %{id: id, email: email}} = signup()
    assert {:ok, %{id: ^id}} = Authentication.authenticate(email, "password", church)
  end

  test "authenticate/2 returns error with invalid credentials" do
    %{church: church, user: user} = signup()
    assert Authentication.authenticate("bla@mail.com", "12341234", church) == :error
    assert Authentication.authenticate(user.email, "12341234", church) == :error
  end
end
