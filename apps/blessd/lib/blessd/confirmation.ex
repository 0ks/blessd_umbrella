defmodule Blessd.Confirmation do
  @moduledoc """
  The Confirmation context.
  """

  import Ecto.Query

  alias Blessd.Auth
  alias Blessd.Auth.Church
  alias Blessd.Confirmation.User
  alias Blessd.Repo

  def generate_token(%User{} = user) do
    user
    |> User.token_changeset()
    |> Repo.update()
  end

  def generate_token(%{id: user_id, church: church}) do
    User
    |> Repo.get!(user_id)
    |> Map.put(:church, church)
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

  defp get_user_by_token(token, %Church{id: church_id}) do
    User
    |> where([u], u.church_id == ^church_id and u.confirmation_token == ^token)
    |> preload([u], :church)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
