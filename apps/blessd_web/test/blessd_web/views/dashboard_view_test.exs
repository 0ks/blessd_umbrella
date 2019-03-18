defmodule BlessdWeb.DashboardViewTest do
  use ExUnit.Case

  alias BlessdWeb.DashboardView

  test "show_card? returns if a card must be shown or not" do
    resources = %{user: %{confirmed_at: nil}, most_missed: [1], todays_meetings: [1]}
    assert DashboardView.show_card?(:confirmation, resources)
    assert DashboardView.show_card?(:most_missed, resources)
    assert DashboardView.show_card?(:todays_meetings, resources)

    resources = %{user: %{confirmed_at: true}, most_missed: [], todays_meetings: []}
    refute DashboardView.show_card?(:confirmation, resources)
    refute DashboardView.show_card?(:most_missed, resources)
    refute DashboardView.show_card?(:todays_meetings, resources)
  end

  test "show_any_card? returns if any card must be shown" do
    resources = %{user: %{confirmed_at: nil}, most_missed: [1], todays_meetings: [1]}
    assert DashboardView.show_any_card?(resources)
    assert DashboardView.show_any_card?(resources)
    assert DashboardView.show_any_card?(resources)

    resources = %{user: %{confirmed_at: true}, most_missed: [], todays_meetings: []}
    refute DashboardView.show_any_card?(resources)
  end
end
