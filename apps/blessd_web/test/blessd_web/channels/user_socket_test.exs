defmodule BlessdWeb.UserSocketTest do
  use BlessdWeb.ChannelCase

  alias BlessdWeb.UserSocket

  test "connects using a token" do
    socket = socket(UserSocket, "meeting_occurrence:lobby", %{})
    user = signup()
    token = Phoenix.Token.sign(socket, "user socket", {user.id, user.church.id})
    assert {:ok, _} = connect(UserSocket, %{"token" => token})
    assert :error = connect(UserSocket, %{"token" => nil})
  end
end
