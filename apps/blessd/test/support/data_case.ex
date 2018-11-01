defmodule Blessd.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias Blessd.Signup

  using do
    quote do
      alias Blessd.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Blessd.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Blessd.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Blessd.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @signup_attrs %{
    "church" => %{name: "Test Church", identifier: "test_church"},
    "user" => %{name: "Test User", email: "test_user@mail.com"},
    "credential" => %{source: "password", token: "password"}
  }

  def signup(original? \\ false) do
    {:ok, user} = Signup.register(@signup_attrs)

    if original? do
      user
    else
      user = %{user | church: convert_struct!(user.church, Blessd.Auth.Church)}
      convert_struct!(user, Blessd.Auth.User)
    end
  end

  def convert_struct!(struct, target_module) do
    keys =
      target_module
      |> struct!()
      |> Map.keys()

    map =
      struct
      |> Map.from_struct()
      |> Map.take(keys)

    struct!(target_module, map)
  end
end
