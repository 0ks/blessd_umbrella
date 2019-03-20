defmodule BlessdWeb.StringHelpersTest do
  use ExUnit.Case

  alias BlessdWeb.StringHelpers

  test "humanize convert multiple types of data to human understandable strings" do
    naive = ~N[2000-02-01 00:00:00]
    assert StringHelpers.humanize(naive) == "02/01/2000 12:00am"
    assert StringHelpers.humanize(DateTime.from_naive!(naive, "Etc/UTC")) == "02/01/2000 12:00am"
    assert StringHelpers.humanize(~D[2000-02-01]) == "02/01/2000"
    assert StringHelpers.humanize(true) == "Yes"
    assert StringHelpers.humanize(false) == "No"
    assert StringHelpers.humanize(:testing) == "Testing"
  end
end
