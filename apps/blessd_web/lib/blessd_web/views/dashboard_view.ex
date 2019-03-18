defmodule BlessdWeb.DashboardView do
  use BlessdWeb, :view

  @cards ~w(confirmation most_missed todays_meetings)a

  def show_card?(:confirmation, %{user: user}), do: user.confirmed_at == nil
  def show_card?(:most_missed, %{most_missed: people}), do: people != []
  def show_card?(:todays_meetings, %{todays_meetings: meetings}), do: meetings != []

  def show_any_card?(resources), do: Enum.any?(@cards, &show_card?(&1, resources))
end
