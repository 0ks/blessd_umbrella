defmodule Blessd.ChurchRecovery.Credentials do
  @moduledoc """
  Secondary context for credentials
  """

  import Ecto.Query

  alias Blessd.ChurchRecovery.Credentials.Credential
  alias Blessd.ChurchRecovery.Users.User
  alias Blessd.Repo

  def find_by_user(%User{id: user_id} = user) do
    with {:ok, credential} <- find_by_user(user_id) do
      {:ok, Map.put(credential, :user, user)}
    end
  end

  def find_by_user(user_id) do
    Credential
    |> where([c], c.user_id == ^user_id)
    |> Repo.find_by(source: "church_recovery")
  end

  def find_by_token(token) do
    Credential
    |> where([c], c.token == ^token)
    |> Repo.find_by(source: "church_recovery")
  end

  def create_or_update(%User{id: id} = user) do
    case find_by_user(user) do
      {:ok, credential} ->
        credential
        |> Credential.changeset()
        |> Repo.update()

      {:error, :not_found} ->
        %Credential{church_id: user.church_id, user_id: id, user: user}
        |> Credential.changeset()
        |> Repo.insert()
    end
  end

  def delete(%Credential{} = credential), do: Repo.delete(credential)
end
