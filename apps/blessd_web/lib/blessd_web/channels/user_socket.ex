defmodule BlessdWeb.UserSocket do
  use Phoenix.Socket

  alias Blessd.Auth

  ## Channels
  channel("attendance:*", BlessdWeb.AttendanceChannel)

  ## Transports
  transport(:websocket, Phoenix.Transports.WebSocket)

  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
      {:ok, church_id} ->
        # TODO - change current_church to current_user when user is created
        {:ok, assign(socket, :current_church, Auth.get_church!(church_id))}

      {:error, _reason} ->
        :error
    end
  end

  def id(_socket), do: nil
end
