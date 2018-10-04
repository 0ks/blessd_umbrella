defmodule Blessd.MembershipsTest do
  use Blessd.DataCase

  alias Blessd.Memberships

  describe "people" do
    alias Blessd.Memberships.Person

    @valid_attrs %{email: "some@email.com", name: "some name", is_member: true}
    @update_attrs %{email: "updated@email.com", name: "some updated name", is_member: false}
    @invalid_attrs %{email: nil, name: nil, is_member: nil}

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
      assert person.email == "some@email.com"
      assert person.name == "some name"
    end

    test "create_person/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Memberships.create_person(@invalid_attrs)
    end

    test "create_people/1 with valid data creates a lot of people" do
      assert {:ok, people} = Memberships.create_people([@valid_attrs, @update_attrs])
      assert [%Person{} = p1, %Person{} = p2] = people

      assert p1.email == "some@email.com"
      assert p1.name == "some name"
      assert p1.is_member == true

      assert p2.email == "updated@email.com"
      assert p2.name == "some updated name"
      assert p2.is_member == false
    end

    test "create_people/1 with invalid data returns error changeset" do
      assert {:error, 1, %Ecto.Changeset{}} =
               Memberships.create_people([@valid_attrs, @invalid_attrs])
    end

    test "import_people/1 with valid data creates a lot of people" do
      assert {:ok, people} =
               [
                 Map.keys(@valid_attrs),
                 Map.values(@valid_attrs),
                 Map.values(@update_attrs)
               ]
               |> Stream.map(&Enum.join(&1, ","))
               |> Memberships.import_people()

      assert [%Person{} = p1, %Person{} = p2] = people

      assert p1.email == "some@email.com"
      assert p1.name == "some name"
      assert p1.is_member == true

      assert p2.email == "updated@email.com"
      assert p2.name == "some updated name"
      assert p2.is_member == false
    end

    test "import_people/1 with invalid data returns error changeset" do
      assert {:error, 3, %Ecto.Changeset{}} =
               [
                 Map.keys(@valid_attrs),
                 Map.values(@valid_attrs),
                 Map.values(@invalid_attrs)
               ]
               |> Stream.map(&Enum.join(&1, ","))
               |> Memberships.import_people()
    end

    test "update_person/2 with valid data updates the person" do
      person = person_fixture()
      assert {:ok, person} = Memberships.update_person(person, @update_attrs)
      assert %Person{} = person
      assert person.email == "updated@email.com"
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
