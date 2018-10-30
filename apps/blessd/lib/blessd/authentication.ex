defmodule Blessd.Authentication do
  @moduledoc """
  The Authentication context.
  """

  import Ecto.Query

  alias Blessd.Auth
  alias Blessd.Authentication.Credential
  alias Blessd.Repo

  @doc """
  Authenticates the user by email and password.
  """
  def authenticate(email, password, church) do
    with {:ok, credential} <- get_password_credential(email, church),
         true <- Comeonin.Bcrypt.checkpw(password, credential.token) do
      {:ok, credential.user}
    else
      {:error, :no_credential} ->
        Comeonin.Bcrypt.dummy_checkpw()
        :error

      false ->
        :error
    end
  end

  defp get_password_credential(email, church) do
    Credential
    |> join(:left, [c], assoc(c, :user))
    |> where([c, u], u.email == ^email and c.source == "password")
    |> preload([c, u], user: u)
    |> Auth.check!(church)
    |> Repo.one()
    |> case do
      nil -> {:error, :no_credential}
      credential -> {:ok, credential}
    end
  end
end
