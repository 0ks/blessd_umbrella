defmodule Blessd.Invitation do
  @moduledoc """
  The Invitation context.
  """

  alias Blessd.Auth
  alias Blessd.Invitation.Credential
  alias Blessd.Invitation.User
  alias Blessd.Repo
  alias Ecto.Multi

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

  def accept(user, credential_attrs) do
    credential_changeset =
      user
      |> new_credential()
      |> Credential.changeset(credential_attrs)

    Multi.new()
    |> Multi.update(:user, User.accept_changeset(user))
    |> Multi.insert(:credential, credential_changeset)
    |> Repo.transaction()
  end

  defp new_credential(user), do: %Credential{church_id: user.church_id, user_id: user.id}

  def find_user_by_token(token, identifier) when is_binary(identifier) do
    with {:ok, church} <- Auth.find_church(identifier), do: find_user_by_token(token, church)
  end

  def find_user_by_token(token, church) do
    User
    |> User.by_church(church)
    |> User.by_token(token)
    |> User.preload()
    |> Repo.single()
  end
end
