defmodule BlessdWeb.Session do
  import Plug.Conn

  alias Blessd.Auth

  def get_user(%Plug.Conn{params: %{"church_identifier" => church_identifier}} = conn) do
    conn
    |> list_users()
    |> Enum.find(fn user ->
      user.church_id == church_identifier || user.church.identifier == church_identifier
    end)
  end

  def list_users(conn) do
    case get_session(conn, :users) do
      nil ->
        []

      users ->
        users
        |> Stream.filter(&elem(&1, 1))
        |> Enum.map(fn {church_id, user_id} ->
          Auth.get_user!(user_id, church_id)
        end)
    end
  end

  def put_user(conn, user) do
    case get_session(conn, :users) do
      nil -> put_session(conn, :users, %{user.church_id => user.id})
      %{} = users -> put_session(conn, :users, Map.put(users, user.church_id, user.id))
    end
  end

  def delete_user(conn), do: delete_user(conn, get_user(conn))

  def delete_user(conn, user) do
    users = get_session(conn, :users)

    put_session(conn, :users, Map.delete(users, user.church_id))
  end
end
