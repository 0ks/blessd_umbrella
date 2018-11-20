defmodule BlessdWeb.AttendanceChannelTest do
  use BlessdWeb.ChannelCase

  alias BlessdWeb.AttendanceChannel

  alias Blessd.Memberships
  alias Blessd.Observance
  alias Blessd.Observance.Person

  setup do
    user = signup()

    {:ok, _person} = Memberships.create_person(%{name: "person 1", is_member: true}, user)
    {:ok, _person} = Memberships.create_person(%{name: "person 2", is_member: false}, user)

    {:ok, %{occurrences: [occurrence]}} =
      Observance.create_meeting(
        %{"name" => "some name", "occurrences" => %{"0" => %{date: ~D[2018-09-23]}}},
        user
      )

    {:ok, people} = Observance.list_people(user)

    {:ok, _, socket} =
      UserSocket
      |> socket("user_id", %{current_user: user})
      |> subscribe_and_join(AttendanceChannel, "attendance:lobby")

    {:ok, socket: socket, occurrence: occurrence, people: people}
  end

  test "search replies with html", %{socket: socket, occurrence: occurrence} do
    ref = push(socket, "search", %{"meeting_occurrence_id" => occurrence.id, "query" => "bla"})
    assert_reply(ref, :ok, %{table_body: ""})

    ref = push(socket, "search", %{"meeting_occurrence_id" => occurrence.id, "query" => "1"})
    assert_reply(ref, :ok, %{table_body: body})
    assert String.contains?(body, "person 1")
    refute String.contains?(body, "person 2")
  end

  test "toggle replies with ok", %{socket: socket, occurrence: occurrence, people: people} do
    person = List.first(people)
    refute Person.present?(person, occurrence)

    ref =
      push(socket, "toggle", %{"person_id" => person.id, "meeting_occurrence_id" => occurrence.id})

    assert_reply(ref, :ok)

    ref = push(socket, "search", %{"meeting_occurrence_id" => occurrence.id, "query" => "1"})
    assert_reply(ref, :ok, %{table_body: body})
    assert String.contains?(body, "person 1")
    assert String.contains?(body, "checked")

    ref = push(socket, "search", %{"meeting_occurrence_id" => occurrence.id, "query" => "2"})
    assert_reply(ref, :ok, %{table_body: body})
    assert String.contains?(body, "person 2")
    refute String.contains?(body, "checked")
  end
end
