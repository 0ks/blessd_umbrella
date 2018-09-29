defmodule Blessd.ServiceAttendant.Queries do
  import Ecto.Query

  def order_preloaded(query) do
    order_by(query, [a, p], p.name)
  end

  def preload(query) do
    query
    |> join(:inner, [a], p in assoc(a, :person))
    |> preload([a, p], [person: p])
  end
end
