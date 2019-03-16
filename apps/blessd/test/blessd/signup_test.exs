defmodule Blessd.SignupTest do
  use Blessd.DataCase

  alias Blessd.Signup
  alias Blessd.Signup.Church
  alias Blessd.Signup.User
  alias Blessd.Signup.Credential

  @valid_attrs %{
    "church" => %{name: "some name", slug: "some_slug", timezone: "UTC"},
    "user" => %{name: "some name", email: "some@email"},
    "credential" => %{source: "password", token: "password"}
  }
  @invalid_attrs %{
    "church" => %{name: nil, slug: nil, timezone: nil},
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
    assert church.slug == "some_slug"

    assert user.name == "some name"
    assert user.email == "some@email"

    assert credential.source == "password"
    assert Comeonin.Bcrypt.checkpw("password", credential.token)
  end

  test "register/1 returns error for duplicated registers" do
    assert {:ok, %User{}} = Signup.register(@valid_attrs)
    assert {:error, %Ecto.Changeset{}} = Signup.register(@valid_attrs)
  end

  test "register/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Signup.register(@invalid_attrs)
  end

  test "new_registration/0 returns a changeset for a new signup" do
    assert %Ecto.Changeset{data: data} = Signup.new_registration()
    assert data.church == %Church{}
    assert data.user == %User{}
    assert data.credential == %Credential{source: "password"}
  end
end
