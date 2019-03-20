defmodule BlessdWeb.MeetingOccurrenceChannelTest do
  use BlessdWeb.ChannelCase

  alias Blessd.Observance
  alias Blessd.Memberships
  alias BlessdWeb.MeetingOccurrenceChannel

  @valid_meeting_attrs %{
    "name" => "some name",
    "occurrences" => %{"0" => %{date: ~D[2018-10-10]}}
  }

  def meeting_fixture(attrs \\ %{}, user) do
    {:ok, meeting} =
      attrs
      |> Enum.into(@valid_meeting_attrs)
      |> Observance.create_meeting(user)

    meeting
  end

  @signup_attrs %{
    "church" => %{name: "Another Church", slug: "another_church", timezone: "UTC"},
    "user" => %{name: "Test User", email: "test_user@mail.com"},
    "credential" => %{source: "password", token: "password"}
  }

  test "search searchs for people on occurrence" do
    user = signup()

    %{occurrences: [occurrence]} = meeting_fixture(user)

    {:ok, _} = Memberships.create_person(%{name: "John", is_member: true}, user)
    {:ok, _} = Memberships.create_person(%{name: "Mary", is_member: false}, user)

    {:ok, _, socket} =
      UserSocket
      |> socket("meeting_occurrence:lobby", %{current_user: user})
      |> subscribe_and_join(MeetingOccurrenceChannel, "meeting_occurrence:lobby")

    ref =
      push(
        socket,
        "search",
        %{"meeting_occurrence_id" => occurrence.id, "query" => "jo", "filter" => nil}
      )

    assert_reply ref, :ok, %{table_body: table_body}
    assert table_body =~ "John"
    refute table_body =~ "Mary"

    ref =
      push(
        socket,
        "search",
        %{"meeting_occurrence_id" => occurrence.id, "query" => "ma", "filter" => nil}
      )

    assert_reply ref, :ok, %{table_body: table_body}
    refute table_body =~ "John"
    assert table_body =~ "Mary"

    user2 = signup(@signup_attrs)

    {:ok, _, socket} =
      UserSocket
      |> socket("meeting_occurrence:lobby", %{current_user: user2})
      |> subscribe_and_join(MeetingOccurrenceChannel, "meeting_occurrence:lobby")

    ref =
      push(
        socket,
        "search",
        %{"meeting_occurrence_id" => occurrence.id, "query" => "ma", "filter" => nil}
      )

    assert_reply ref, :error, %{message: "Occurrence not found"}
  end

  test "create creates a new person" do
    user = signup()

    %{occurrences: [occurrence]} = meeting_fixture(user)

    {:ok, _, socket} =
      UserSocket
      |> socket("meeting_occurrence:lobby", %{current_user: user})
      |> subscribe_and_join(MeetingOccurrenceChannel, "meeting_occurrence:lobby")

    ref =
      push(
        socket,
        "create",
        %{
          "meeting_occurrence_id" => occurrence.id,
          "person" => %{"name" => "Beth", "is_member" => false}
        }
      )

    assert_reply ref, :ok, %{table_body: table_body}
    assert table_body =~ "Beth"

    ref =
      push(
        socket,
        "create",
        %{
          "meeting_occurrence_id" => occurrence.id,
          "person" => %{}
        }
      )

    assert_reply ref, :error, %{name: "can't be blank"}
  end

  test "update_state updates the state of a given person" do
    user = signup()

    %{occurrences: [occurrence]} = meeting_fixture(user)

    {:ok, person} = Memberships.create_person(%{name: "John", is_member: true}, user)

    {:ok, _, socket} =
      UserSocket
      |> socket("meeting_occurrence:lobby", %{current_user: user})
      |> subscribe_and_join(MeetingOccurrenceChannel, "meeting_occurrence:lobby")

    ref =
      push(
        socket,
        "update_state",
        %{
          "meeting_occurrence_id" => occurrence.id,
          "person_id" => person.id,
          "state" => "recurrent"
        }
      )

    assert_reply ref, :ok, %{table_row: table_row}
    assert table_row =~ "is-recurrent\n               is-active"
  end
end
