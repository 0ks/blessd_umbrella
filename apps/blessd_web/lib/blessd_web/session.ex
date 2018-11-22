defmodule BlessdWeb.Session do
  import Plug.Conn

  alias Blessd.Auth

  def find_user(%Plug.Conn{params: %{"church_identifier" => church_identifier}} = conn) do
    with {:ok, users} <- list_users(conn) do
      users
      |> Enum.find(fn user ->
        to_string(user.church_id) == church_identifier or
          user.church.identifier == church_identifier
      end)
      |> case do
        nil -> {:error, :not_found}
        user -> {:ok, user}
      end
    end
  end

  def list_users(conn) do
    case get_session(conn, :users) do
      nil ->
        {:ok, []}

      users ->
        users =
          users
          |> Stream.filter(&elem(&1, 1))
          |> Stream.map(fn {church_id, user_id} ->
            Auth.find_user(user_id, church_id)
          end)
          |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
          |> Map.get(:ok, [])

        {:ok, users}
    end
  end

  def put_user(conn, user) do
    case get_session(conn, :users) do
      nil -> put_session(conn, :users, %{user.church_id => user.id})
      %{} = users -> put_session(conn, :users, Map.put(users, user.church_id, user.id))
    end
  end

  def delete_user(conn), do: with({:ok, user} <- find_user(conn), do: delete_user(conn, user))

  def delete_user(conn, user) do
    users = get_session(conn, :users)

    put_session(conn, :users, Map.delete(users, user.church_id))
  end
end
