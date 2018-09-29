defmodule BlessdWeb.FormHelpers do
  def form_action(:create, _, route_helper), do: route_helper.(:create, [])
  def form_action(:update, changeset, route_helper), do: route_helper.(:update, changeset.data)
end
