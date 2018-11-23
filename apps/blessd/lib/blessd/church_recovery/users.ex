defmodule Blessd.ChurchRecovery.Users do
  @moduledoc """
  Secondary context for users
  """

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.ChurchRecovery.Users.User
  alias Blessd.Repo

  def list_by_email(email) do
    User
    |> where([u], u.email == ^email)
    |> preload([u], :church)
    |> Repo.list()
  end

  def find(attrs) do
    with {:ok, %User{email: email}} <- validate(attrs) do
      User
      |> where([u], u.email == ^email)
      |> preload([u], :church)
      |> Repo.all()
      |> case do
        [user | _] -> {:ok, user}
        [] -> {:error, :not_found}
      end
    end
  end

  def find_by_token(token) do
    User
    |> join(:inner, [u], assoc(u, :credentials), as: :credentials)
    |> where([u, credentials: c], c.token == ^token and c.source == "church_recovery")
    |> Repo.single()
  end

  def validate(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> apply_action(:insert)
  end

  def new, do: {:ok, User.changeset(%User{}, %{})}
end
