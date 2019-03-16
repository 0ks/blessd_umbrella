defmodule Blessd.ObservanceTest do
  use Blessd.DataCase

  alias Blessd.Observance

  @valid_meeting_attrs %{
    "name" => "some name",
    "occurrences" => %{"0" => %{date: ~D[2018-10-10]}}
  }
  @update_meeting_attrs %{
    "name" => "updated name",
    "occurrences" => %{"0" => %{date: ~D[2000-01-01]}}
  }
  @invalid_meeting_attrs %{name: nil}

  @valid_occurrence_attrs %{"date" => ~D[2019-03-16]}
  @update_occurrence_attrs %{"date" => ~D[2020-03-16]}
  @invalid_occurrence_attrs %{"date" => nil}

  def meeting_fixture(attrs \\ %{}, user) do
    {:ok, meeting} =
      attrs
      |> Enum.into(@valid_meeting_attrs)
      |> Observance.create_meeting(user)

    meeting
  end

  describe "meetings" do
    alias Blessd.Observance.Meetings.Meeting

    test "list_meetings/0 returns all meetings" do
      user = signup()
      meeting = meeting_fixture(user)
      assert {:ok, [found]} = Observance.list_meetings(user)

      assert found.name == meeting.name
    end

    test "find_meeting/1 returns the meeting with given id" do
      user = signup()
      meeting = meeting_fixture(user)
      assert {:ok, found} = Observance.find_meeting(meeting.id, user)

      assert found.name == meeting.name
    end

    test "create_meeting/1 with valid data creates a meeting" do
      user = signup()
      assert {:ok, %Meeting{} = meeting} = Observance.create_meeting(@valid_meeting_attrs, user)
      assert meeting.name == "some name"
    end

    test "create_meeting/1 with invalid data returns error changeset" do
      user = signup()
      assert {:error, %Ecto.Changeset{}} = Observance.create_meeting(@invalid_meeting_attrs, user)
    end

    test "update_meeting/2 with valid data updates the meeting" do
      user = signup()
      meeting = meeting_fixture(user)

      assert {:ok, %Meeting{} = meeting} =
               Observance.update_meeting(meeting.id, @update_meeting_attrs, user)

      assert meeting.name == "updated name"
    end

    test "update_meeting/2 with invalid data returns error changeset" do
      user = signup()
      meeting = meeting_fixture(user)

      assert {:error, %Ecto.Changeset{}} =
               Observance.update_meeting(meeting.id, @invalid_meeting_attrs, user)

      assert {:ok, found} = Observance.find_meeting(meeting.id, user)

      assert found.name == meeting.name
    end

    test "delete_meeting/1 deletes the meeting" do
      user = signup()
      meeting = meeting_fixture(user)
      assert {:ok, %Meeting{}} = Observance.delete_meeting(meeting.id, user)
      assert {:error, :not_found} == Observance.find_meeting(meeting.id, user)
    end

    test "new_meeting_changeset/1 creates a changeset for a new meeting" do
      user = signup()

      assert {:ok, %Ecto.Changeset{}} = Observance.new_meeting_changeset(user)
    end

    test "edit_meeting_changeset/1 creates a changeset to edit an existing meeting" do
      user = signup()
      %{id: id} = meeting_fixture(user)

      assert {:ok, %Ecto.Changeset{data: %{id: ^id}}} =
               Observance.edit_meeting_changeset(id, user)

      assert {:error, :not_found} = Observance.edit_meeting_changeset(0, user)
    end
  end

  describe "meeting_occurrences" do
    alias Blessd.Observance.Meetings.Occurrences.Occurrence
    alias Blessd.Memberships

    test "list_occurrences/1 returns all occurrences" do
      user = signup()
      %{occurrences: [occurrence]} = meeting_fixture(user)
      assert {:ok, [found]} = Observance.list_occurrences(user)

      assert found.meeting_id == occurrence.meeting_id
      assert found.date == occurrence.date
    end

    test "find_occurrence/2 returns the meeting with given id" do
      user = signup()
      %{occurrences: [occurrence]} = meeting_fixture(user)
      assert {:ok, found} = Observance.find_occurrence(occurrence.id, user)

      assert found.meeting_id == occurrence.meeting_id
      assert found.date == occurrence.date
    end

    test "create_occurrence/3 with valid data creates a meeting" do
      user = signup()
      meeting = meeting_fixture(user)

      assert {:ok, %Occurrence{} = occurrence} =
               Observance.create_occurrence(meeting, @valid_occurrence_attrs, user)

      assert occurrence.meeting_id == meeting.id
      assert occurrence.date == ~D[2019-03-16]
    end

    test "create_occurrence/1 with invalid data returns error changeset" do
      user = signup()
      meeting = meeting_fixture(user)

      assert {:error, %Ecto.Changeset{}} =
               Observance.create_occurrence(meeting, @invalid_occurrence_attrs, user)
    end

    test "update_occurrence/2 with valid data updates the meeting" do
      user = signup()
      %{occurrences: [occurrence]} = meeting = meeting_fixture(user)

      assert {:ok, %Occurrence{} = occurrence} =
               Observance.update_occurrence(occurrence.id, @update_occurrence_attrs, user)

      assert occurrence.meeting_id == meeting.id
      assert occurrence.date == ~D[2020-03-16]
    end

    test "update_occurrence/2 with invalid data returns error changeset" do
      user = signup()
      %{occurrences: [occurrence]} = meeting_fixture(user)

      assert {:error, %Ecto.Changeset{}} =
               Observance.update_occurrence(occurrence.id, @invalid_occurrence_attrs, user)

      assert {:ok, found} = Observance.find_occurrence(occurrence.id, user)

      assert found.meeting_id == occurrence.meeting_id
      assert found.date == occurrence.date
    end

    test "delete_occurrence/1 deletes the meeting" do
      user = signup()
      %{occurrences: [occurrence]} = meeting_fixture(user)
      assert {:ok, %Occurrence{}} = Observance.delete_occurrence(occurrence.id, user)
      assert {:error, :not_found} == Observance.find_occurrence(occurrence.id, user)
    end

    test "new_occurrence_changeset/1 creates a changeset for a new meeting" do
      user = signup()
      meeting = meeting_fixture(user)

      assert {:ok, %Ecto.Changeset{}} = Observance.new_occurrence_changeset(meeting.id, user)
    end

    test "edit_meeting_changeset/1 creates a changeset to edit an existing meeting" do
      user = signup()
      %{occurrences: [%{id: id}]} = meeting_fixture(user)

      assert {:ok, %Ecto.Changeset{data: %{id: ^id}}} =
               Observance.edit_occurrence_changeset(id, user)

      assert {:error, :not_found} = Observance.edit_occurrence_changeset(0, user)
    end

    test "attendance_stats/2 resturns the stats for a given occurrence attendance" do
      user = signup()
      %{occurrences: [occurrence]} = meeting_fixture(user)

      assert {:ok, stats} = Observance.attendance_stats(occurrence, user)

      assert stats == %{
               absent: 0,
               first_time: 0,
               missing: 0,
               present: 0,
               recurrent: 0,
               total: 0,
               unknown: 0
             }
    end

    test "list_people/2 lists the people" do
      user = signup()
      {:ok, _} = Memberships.create_person(%{name: "John", is_member: false}, user)
      assert {:ok, [found]} = Observance.list_people(user)

      assert found.name == "John"
    end

    test "update_attendant_state/2 updates the attendant state" do
      user = signup()
      %{occurrences: [occurrence]} = meeting_fixture(user)
      {:ok, person} = Memberships.create_person(%{name: "John", is_member: false}, user)

      assert {:ok, stats} = Observance.attendance_stats(occurrence, user)

      assert stats == %{
               absent: 0,
               first_time: 0,
               missing: 1,
               present: 0,
               recurrent: 0,
               total: 0,
               unknown: 1
             }

      assert {:ok, _} =
               Observance.update_attendant_state(person.id, occurrence.id, "absent", user)

      assert {:ok, stats} = Observance.attendance_stats(occurrence, user)

      assert stats == %{
               absent: 1,
               first_time: 0,
               missing: 1,
               present: 0,
               recurrent: 0,
               total: 0,
               unknown: 0
             }

      assert {:ok, _} =
               Observance.update_attendant_state(person.id, occurrence.id, "first_time", user)

      assert {:ok, stats} = Observance.attendance_stats(occurrence, user)

      assert stats == %{
               absent: 0,
               first_time: 1,
               missing: 0,
               present: 1,
               recurrent: 0,
               total: 0,
               unknown: 0
             }

      assert {:ok, _} =
               Observance.update_attendant_state(person.id, occurrence.id, "recurrent", user)

      assert {:ok, stats} = Observance.attendance_stats(occurrence, user)

      assert stats == %{
               absent: 0,
               first_time: 0,
               missing: 0,
               present: 1,
               recurrent: 1,
               total: 0,
               unknown: 0
             }

      assert {:ok, _} =
               Observance.update_attendant_state(person.id, occurrence.id, "unknown", user)

      assert {:ok, stats} = Observance.attendance_stats(occurrence, user)

      assert stats == %{
               absent: 0,
               first_time: 0,
               missing: 1,
               present: 0,
               recurrent: 0,
               total: 0,
               unknown: 1
             }
    end
  end
end
