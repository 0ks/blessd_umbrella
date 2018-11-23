defmodule Blessd.Auth.Users do
  @moduledoc false

  alias Blessd.Auth.Churches
  alias Blessd.Auth.Churches.Church
  alias Blessd.Auth.Users.User
  alias Blessd.Repo

  @doc false
  def find(id, church_id) when is_binary(church_id) or is_integer(church_id) do
    with {:ok, church} <- Churches.find(church_id), do: find(id, church)
  end

  def find(id, %Church{} = church) do
    with {:ok, query} <- Churches.check(User, church),
         {:ok, user} <- Repo.find(query, id) do
      {:ok, Map.put(user, :church, church)}
    end
  end

  @doc false
  def check(_, %User{confirmed_at: nil}), do: {:error, :unconfirmed}
  def check(checkable, %User{church: church}), do: Churches.check(checkable, church)
end
