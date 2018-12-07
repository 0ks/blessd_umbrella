defmodule Blessd.Confirmation do
  @moduledoc """
  The Confirmation context.
  """

  alias Blessd.Shared
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

  def confirm(token, slug) when is_binary(slug) do
    with {:ok, church} <- Shared.find_church(slug), do: confirm(token, church)
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
    with {:ok, query} <- Shared.authorize(User, church) do
      query
      |> User.preload()
      |> Repo.find_by(confirmation_token: token)
    end
  end
end
