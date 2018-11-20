defmodule Blessd.AuthenticationTest do
  use Blessd.DataCase

  alias Blessd.Authentication
  alias Blessd.Authentication.Session
  alias Blessd.Authentication.User

  @signup2_attrs %{
    "church" => %{name: "Test Church 2", identifier: "test_church2"},
    "user" => %{name: "Test User", email: "test_user@mail.com"},
    "credential" => %{source: "password", token: "password"}
  }

  test "authenticate/2 authenticates a user by its email and password" do
    %{church: church, id: id, email: email} = signup()

    assert {:ok, %Session{user: %User{id: ^id}}} =
             Authentication.authenticate(%{
               email: email,
               password: "password",
               church_identifier: church.identifier
             })

    %{church: church2, id: id2, email: ^email} = signup(@signup2_attrs)

    assert {:ok, %Session{user: %User{id: ^id2}}} =
             Authentication.authenticate(%{
               email: email,
               password: "password",
               church_identifier: church2.identifier
             })
  end

  test "authenticate/2 returns error with invalid credentials" do
    %{church: church, email: email} = signup()

    assert {:error, %Ecto.Changeset{}} =
             Authentication.authenticate(%{
               email: "bla@mail.com",
               password: "12341234",
               church_identifier: church.identifier
             })

    assert {:error, %Ecto.Changeset{}} =
             Authentication.authenticate(%{
               email: email,
               password: "12341234",
               church_identifier: church.identifier
             })
  end
end
