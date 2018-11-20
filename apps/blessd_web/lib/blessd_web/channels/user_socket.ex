defmodule BlessdWeb.UserSocket do
  use Phoenix.Socket

  alias Blessd.Auth

  ## Channels
  channel("attendance:*", BlessdWeb.AttendanceChannel)

  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
      {:ok, {user_id, church_id}} ->
        case Auth.find_user(user_id, church_id) do
          {:ok, user} -> {:ok, assign(socket, :current_user, user)}
          {:error, :not_found} -> :error
        end

      {:error, _reason} ->
        :error
    end
  end

  def id(_socket), do: nil
end
