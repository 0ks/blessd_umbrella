defmodule Blessd.ChurchRecovery do
  @moduledoc """
  Functions for dealing with church recovery.
  """

  alias Blessd.ChurchRecovery.Credentials
  alias Blessd.ChurchRecovery.Users

  def new_user, do: Users.new()

  def generate_token(attrs) do
    with {:ok, user} <- Users.find(attrs) do
      Credentials.create_or_update(user)
    end
  end

  def list_users(token) do
    with {:ok, user} <- Users.find_by_token(token) do
      Users.list_by_email(user.email)
    end
  end

  def recover(token) do
    with {:ok, credential} <- Credentials.find_by_token(token) do
      Credentials.delete(credential)
    end
  end
end
