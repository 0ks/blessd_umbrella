defmodule Blessd.CustomTest do
  use Blessd.DataCase

  alias Blessd.Custom
  alias Blessd.Custom.Fields.Field

  @valid_attrs %{name: "some name", type: "string", validations: %{required: true}}
  @update_attrs %{name: "another name", type: "date"}
  @invalid_attrs %{name: nil, type: nil}

  def field_fixture(resource, attrs \\ %{}, user) do
    attrs = Enum.into(attrs, @valid_attrs)
    {:ok, field} = Custom.create_field(resource, attrs, user)
    field
  end

  test "list_fields returns all fields" do
    user = signup()
    field = field_fixture("person", user)
    assert {:ok, [found]} = Custom.list_fields("person", user)

    assert found.name == field.name
  end

  test "new_field_changeset returns a changeset to create a new field" do
    user = signup()
    assert {:ok, %Ecto.Changeset{}} = Custom.new_field_changeset("person", user)
  end

  test "edit_field_changeset returns a changeset to create a new field" do
    user = signup()
    field = field_fixture("person", user)
    assert {:ok, %Ecto.Changeset{}} = Custom.edit_field_changeset(field.id, user)
  end

  test "update_field/2 with valid data updates the field" do
    user = signup()
    field = field_fixture("person", user)
    assert {:ok, %Field{} = field} = Custom.update_field(field.id, @update_attrs, user)
    assert field.name == "another name"
  end

  test "update_field/2 with invalid data returns error changeset" do
    user = signup()
    field = field_fixture("person", user)
    assert {:error, %Ecto.Changeset{}} = Custom.update_field(field.id, @invalid_attrs, user)
    assert {:ok, [found]} = Custom.list_fields("person", user)
    assert found.id == field.id
    assert found.name == field.name
  end

  test "reorder_fields reorders the fields" do
    user = signup()
    field1 = field_fixture("person", user)
    field2 = field_fixture("person", user)
    assert {:ok, fields} = Custom.list_fields("person", user)
    assert Enum.map(fields, & &1.id) == [field1.id, field2.id]

    assert {:ok, _} = Custom.reorder_fields("person", [field2.id, field1.id], user)
    assert {:ok, fields} = Custom.list_fields("person", user)
    assert Enum.map(fields, & &1.id) == [field2.id, field1.id]
  end

  test "delete_field deletes the field" do
    user = signup()
    field = field_fixture("person", user)
    assert {:ok, %Field{}} = Custom.delete_field(field.id, user)
    assert {:ok, []} = Custom.list_fields("person", user)
  end
end
