defmodule Blessd.Shared.Users do
  @moduledoc false

  alias Blessd.Shared.Churches
  alias Blessd.Shared.Churches.Church
  alias Blessd.Shared.Users.User
  alias Blessd.Repo

  @doc false
  def find(id, church_id) when is_binary(church_id) or is_integer(church_id) do
    with {:ok, church} <- Churches.find(church_id), do: find(id, church)
  end

  def find(id, %Church{} = church) do
    with {:ok, query} <- Churches.authorize(User, church),
         {:ok, user} <- Repo.find(query, id) do
      {:ok, Map.put(user, :church, church)}
    end
  end

  @doc false
  def authorize(_, %User{confirmed_at: nil}), do: {:error, :unconfirmed}
  def authorize(resource, %User{church: church}), do: Churches.authorize(resource, church)
end
