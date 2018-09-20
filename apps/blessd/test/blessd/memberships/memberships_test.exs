defmodule Blessd.MembershipsTest do
  use Blessd.DataCase

  alias Blessd.Memberships

  describe "people" do
    alias Blessd.Memberships.Person

    @valid_attrs %{email: "some email", name: "some name"}
    @update_attrs %{email: "some updated email", name: "some updated name"}
    @invalid_attrs %{email: nil, name: nil}

    def person_fixture(attrs \\ %{}) do
      {:ok, person} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Memberships.create_person()

      person
    end

    test "list_people/0 returns all people" do
      person = person_fixture()
      assert Memberships.list_people() == [person]
    end

    test "get_person!/1 returns the person with given id" do
      person = person_fixture()
      assert Memberships.get_person!(person.id) == person
    end

    test "create_person/1 with valid data creates a person" do
      assert {:ok, %Person{} = person} = Memberships.create_person(@valid_attrs)
      assert person.email == "some email"
      assert person.name == "some name"
    end

    test "create_person/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Memberships.create_person(@invalid_attrs)
    end

    test "update_person/2 with valid data updates the person" do
      person = person_fixture()
      assert {:ok, person} = Memberships.update_person(person, @update_attrs)
      assert %Person{} = person
      assert person.email == "some updated email"
      assert person.name == "some updated name"
    end

    test "update_person/2 with invalid data returns error changeset" do
      person = person_fixture()
      assert {:error, %Ecto.Changeset{}} = Memberships.update_person(person, @invalid_attrs)
      assert person == Memberships.get_person!(person.id)
    end

    test "delete_person/1 deletes the person" do
      person = person_fixture()
      assert {:ok, %Person{}} = Memberships.delete_person(person)
      assert_raise Ecto.NoResultsError, fn -> Memberships.get_person!(person.id) end
    end

    test "change_person/1 returns a person changeset" do
      person = person_fixture()
      assert %Ecto.Changeset{} = Memberships.change_person(person)
    end
  end
end
