defmodule BlessdWeb.CustomFieldChannelTest do
  use BlessdWeb.ChannelCase

  alias Blessd.Custom
  alias BlessdWeb.CustomFieldChannel

  @valid_attrs %{name: "some name", type: "string", validations: %{required: true}}

  def field_fixture(resource, attrs \\ %{}, user) do
    attrs = Enum.into(attrs, @valid_attrs)
    {:ok, field} = Custom.create_field(resource, attrs, user)
    field
  end

  @signup_attrs %{
    "church" => %{name: "Another Church", slug: "another_church", language: "en", timezone: "UTC"},
    "user" => %{name: "Test User", email: "test_user@mail.com"},
    "credential" => %{source: "password", token: "password"}
  }

  test "reorder must reorder the fields" do
    user = signup()
    field1 = field_fixture("person", user)
    field2 = field_fixture("person", user)
    assert {:ok, fields} = Custom.list_fields("person", user)
    assert Enum.map(fields, & &1.id) == [field1.id, field2.id]

    {:ok, _, socket} =
      UserSocket
      |> socket("custom_field:lobby", %{current_user: user})
      |> subscribe_and_join(CustomFieldChannel, "custom_field:lobby")

    ref = push(socket, "reorder", %{"resource" => "person", "ids" => [field2.id, field1.id]})
    assert_reply ref, :ok
    assert {:ok, fields} = Custom.list_fields("person", user)
    assert Enum.map(fields, & &1.id) == [field2.id, field1.id]

    user2 = signup(@signup_attrs)

    {:ok, _, socket} =
      UserSocket
      |> socket("custom_field:lobby", %{current_user: user2})
      |> subscribe_and_join(CustomFieldChannel, "custom_field:lobby")

    ref = push(socket, "reorder", %{"resource" => "person", "ids" => [field2.id, field1.id]})
    assert_reply ref, :error, %{message: "Unauthorized user"}
  end
end
