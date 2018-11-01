defmodule Blessd.SignupTest do
  use Blessd.DataCase

  alias Blessd.Signup
  alias Blessd.Signup.Church
  alias Blessd.Signup.User
  alias Blessd.Signup.Credential

  @valid_attrs %{
    "church" => %{name: "some name", identifier: "some_identifier"},
    "user" => %{name: "some name", email: "some@email"},
    "credential" => %{source: "password", token: "password"}
  }
  @invalid_attrs %{
    "church" => %{name: nil, identifier: nil},
    "user" => %{name: nil, email: nil},
    "credential" => %{source: nil, token: nil}
  }

  test "register/1 with valid data creates a church, user and its credential" do
    assert {:ok,
            %User{
              church: %Church{} = church,
              credentials: [%Credential{} = credential]
            } = user} = Signup.register(@valid_attrs)

    assert church.name == "some name"
    assert church.identifier == "some_identifier"

    assert user.name == "some name"
    assert user.email == "some@email"

    assert credential.source == "password"
    assert Comeonin.Bcrypt.checkpw("password", credential.token)
  end

  test "register/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Signup.register(@invalid_attrs)
  end
end
