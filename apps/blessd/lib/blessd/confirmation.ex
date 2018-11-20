defmodule Blessd.Confirmation do
  @moduledoc """
  The Confirmation context.
  """

  alias Blessd.Auth
  alias Blessd.Confirmation.User
  alias Blessd.Repo

  def generate_token(%User{} = user) do
    user
    |> User.token_changeset()
    |> Repo.update()
  end

  def generate_token(%{id: user_id}) do
    with {:ok, user} <- User |> User.preload() |> Repo.find(user_id) do
      generate_token(user)
    end
  end

  def confirm(token, identifier) when is_binary(identifier) do
    with {:ok, church} <- Auth.find_church(identifier), do: confirm(token, church)
  end

  def confirm(token, church) do
    with {:ok, user} <- find_user_by_token(token, church) do
      confirm(user)
    end
  end

  def confirm(user) do
    user
    |> User.confirm_changeset()
    |> Repo.update()
  end

  defp find_user_by_token(token, church) do
    User
    |> User.by_church(church)
    |> User.by_token(token)
    |> User.preload()
    |> Repo.single()
  end
end
