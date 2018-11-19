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
    User
    |> User.preload()
    |> Repo.get!(user_id)
    |> generate_token()
  end

  def confirm(token, identifier) when is_binary(identifier) do
    confirm(token, Auth.get_church!(identifier))
  end

  def confirm(token, church) do
    with {:ok, user} <- get_user_by_token(token, church) do
      confirm(user)
    end
  end

  def confirm(user) do
    user
    |> User.confirm_changeset()
    |> Repo.update()
  end

  defp get_user_by_token(token, church) do
    User
    |> User.by_church(church)
    |> User.by_token(token)
    |> User.preload()
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
