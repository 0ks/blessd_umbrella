defmodule Blessd.SharedTest do
  use Blessd.DataCase

  alias Blessd.Custom

  alias Blessd.Memberships.Person

  alias Blessd.Shared
  alias Blessd.Shared.Churches.Church
  alias Blessd.Shared.Fields
  alias Blessd.Shared.Users.User

  test "find_church/1 finds a church by slug or id" do
    %{church: %{id: id, slug: slug}} = signup()

    assert {:ok, %Church{id: ^id}} = Shared.find_church(id)
    assert {:ok, %Church{id: ^id}} = id |> to_string() |> Shared.find_church()
    assert {:ok, %Church{id: ^id}} = Shared.find_church(slug)
    assert {:error, :not_found} = Shared.find_church(0)
  end

  test "find_user/2 finds the user of a given church" do
    %{church: church, id: id} = signup()

    assert {:ok, %User{id: ^id}} = Shared.find_user(id, church)
    assert {:ok, %User{id: ^id}} = Shared.find_user(id, church.id)
    assert {:ok, %User{id: ^id}} = Shared.find_user(id, to_string(church.id))
    assert {:error, :not_found} = Shared.find_user(id, 0)
    assert {:error, :not_found} = Shared.find_user(0, church)
  end

  test "authorize/2 authorizes the given user or church for a given resource" do
    %{church: church} = user = signup()

    new_user = %User{church_id: church.id}

    assert {:ok, %Ecto.Query{}} = Shared.authorize(User, user)
    assert {:ok, new_user} = Shared.authorize(new_user, user)
    assert {:error, :unauthorized} = Shared.authorize(%User{}, user)

    assert {:ok, %Ecto.Query{}} = Shared.authorize(User, church)
    assert {:ok, new_user} = Shared.authorize(new_user, church)
    assert {:error, :unauthorized} = Shared.authorize(%User{}, church)
  end

  test "custom_data_changeset/4 builds a changeset for custom data" do
    %{church: church} = user = signup()

    assert %Ecto.Changeset{valid?: true} =
             Shared.custom_data_changeset("person", %{}, %{}, church.id)

    {:ok, field} =
      Custom.create_field(
        "person",
        %{name: "Address", type: "string", validations: %{required: true}},
        user
      )

    assert %Ecto.Changeset{valid?: false} =
             Shared.custom_data_changeset(
               "person",
               %{Fields.name(field) => "Back Street, 101"},
               %{Fields.name(field) => nil},
               church.id
             )

    assert %Ecto.Changeset{valid?: true} =
             Shared.custom_data_changeset(
               "person",
               %{(field |> Fields.name() |> to_string()) => nil},
               %{Fields.name(field) => "Back Street, 101"},
               church.id
             )
  end

  test "put_custom_data/4 puts the custom data changeset on the given resource" do
    %{church: church} = user = signup()

    changeset = Person.changeset(%Person{church_id: church.id}, %{name: "John", is_member: true})

    assert %Ecto.Changeset{valid?: true} =
             Shared.put_custom_data(changeset, :custom_data, "person", %{})

    {:ok, field} =
      Custom.create_field(
        "person",
        %{name: "Address", type: "string", validations: %{required: true}},
        user
      )

    assert %Ecto.Changeset{valid?: false} =
             Shared.put_custom_data(
               changeset,
               :custom_data,
               "person",
               %{Fields.name(field) => nil}
             )

    assert %Ecto.Changeset{valid?: true} =
             Shared.put_custom_data(
               changeset,
               :custom_data,
               "person",
               %{Fields.name(field) => "Back Street, 101"}
             )
  end

  test "list_custom_fields/2 returns the list of custom fields" do
    user = signup()

    {:ok, %{id: id1}} =
      Custom.create_field(
        "person",
        %{name: "Address", type: "string", validations: %{required: true}},
        user
      )

    {:ok, %{id: id2}} =
      Custom.create_field(
        "person",
        %{name: "Birthdate", type: "date", validations: %{required: false}},
        user
      )

    assert {:ok, fields} = Shared.list_custom_fields("person", user)
    ids = Enum.map(fields, & &1.id)
    assert id1 in ids
    assert id2 in ids
  end

  test "custom_field_name/1 returns the custom field name" do
    user = signup()

    {:ok, field} =
      Custom.create_field(
        "person",
        %{name: "Address", type: "string", validations: %{required: true}},
        user
      )

    assert Shared.custom_field_name(field) == :"field#{field.id}"
  end
end
