defmodule Blessd.Repo do
  use Ecto.Repo,
    otp_app: :blessd,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  def list(query) do
    {:ok, all(query)}
  end

  def single(query) do
    case one(query) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  def find(query, id) do
    case get(query, id) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  def find_by(query, params) do
    case get_by(query, params) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end
end
