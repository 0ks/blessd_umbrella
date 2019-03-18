defmodule BlessdWeb.CustomFieldViewTest do
  use ExUnit.Case

  alias BlessdWeb.CustomFieldView

  test "type_options returns the list of options for types select" do
    assert CustomFieldView.type_options() == [{"Short text", "string"}, {"Date", "date"}]
  end
end
