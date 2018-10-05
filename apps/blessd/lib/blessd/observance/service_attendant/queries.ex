defmodule Blessd.Observance.ServiceAttendant.Queries do
  import Ecto.Query

  def order_preloaded(query) do
    order_by(query, [a, p], p.name)
  end

  def preload(query) do
    query
    |> join(:inner, [a], p in assoc(a, :person))
    |> preload([a, p], person: p)
  end

  def by_service(query, service_id) do
    where(query, [a], a.service_id == ^service_id)
  end

  def search(query, query_str) do
    query_str = "%#{query_str}%"

    where(
      query,
      [a, p],
      fragment("? ilike ?", p.name, ^query_str) or fragment("? ilike ?", p.email, ^query_str)
    )
  end
end
