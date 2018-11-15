defmodule BlessdWeb.AttendanceChannelTest do
  use BlessdWeb.ChannelCase

  alias BlessdWeb.AttendanceChannel

  alias Blessd.Memberships
  alias Blessd.Observance

  setup do
    user = signup()

    {:ok, _person} = Memberships.create_person(%{name: "person 1", is_member: true}, user)
    {:ok, _person} = Memberships.create_person(%{name: "person 2", is_member: false}, user)

    {:ok, service} =
      Observance.create_service(
        %{
          name: "some name",
          date: ~D[2005-09-23]
        },
        user
      )

    service = Observance.get_service!(service.id, user)
    attendants = Observance.list_attendants(service, user)

    {:ok, _, socket} =
      UserSocket
      |> socket("user_id", %{current_user: user})
      |> subscribe_and_join(AttendanceChannel, "attendance:lobby")

    {:ok, socket: socket, service: service, attendants: attendants}
  end

  test "search replies with html", %{socket: socket, service: service} do
    ref = push(socket, "search", %{"service_id" => service.id, "query" => "bla"})
    assert_reply(ref, :ok, %{table_body: ""})

    ref = push(socket, "search", %{"service_id" => service.id, "query" => "1"})
    assert_reply(ref, :ok, %{table_body: body})
    assert String.contains?(body, "person 1")
    refute String.contains?(body, "person 2")
  end

  test "update replies with ok", %{socket: socket, service: service, attendants: attendants} do
    attendant = List.first(attendants)
    assert attendant.is_present == false
    ref = push(socket, "update", %{"id" => attendant.id, "attendant" => %{"is_present" => true}})
    assert_reply(ref, :ok)

    ref = push(socket, "search", %{"service_id" => service.id, "query" => "1"})
    assert_reply(ref, :ok, %{table_body: body})
    assert String.contains?(body, "person 1")
    assert String.contains?(body, "checked")

    ref = push(socket, "search", %{"service_id" => service.id, "query" => "2"})
    assert_reply(ref, :ok, %{table_body: body})
    assert String.contains?(body, "person 2")
    refute String.contains?(body, "checked")
  end
end
