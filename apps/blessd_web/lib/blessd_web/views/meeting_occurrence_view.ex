defmodule BlessdWeb.MeetingOccurrenceView do
  use BlessdWeb, :view

  alias Blessd.Observance.Person

  def filter_title(nil), do: gettext("Everyone")
  def filter_title("present"), do: gettext("Present")
  def filter_title("first_time"), do: gettext("First time")
  def filter_title("not_first_time"), do: gettext("Not first time")
  def filter_title("missing"), do: gettext("Missing")
  def filter_title("absent"), do: gettext("Absent")
  def filter_title("unknown"), do: gettext("Unknown")

  def show_state(filter), do: filter in [nil, "present", "missing"]

  def state_icon(:unknown), do: "fa-question"
  def state_icon(:present), do: "fa-check"
  def state_icon(:first_time), do: "fa-heart"
  def state_icon(:absent), do: "fa-times"

  def state_class(state), do: "person-state-#{state}"
end
