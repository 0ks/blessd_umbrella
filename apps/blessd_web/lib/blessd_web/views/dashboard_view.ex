defmodule BlessdWeb.DashboardView do
  use BlessdWeb, :view

  @cards ~w(confirmation)a

  def show_card?(:confirmation, %{user: user}), do: user.confirmed_at == nil

  def show_any_card?(resources), do: Enum.any?(@cards, &show_card?(&1, resources))
end
