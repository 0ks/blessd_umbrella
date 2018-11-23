defmodule BlessdWeb.StringHelpers do
  import BlessdWeb.Gettext

  alias Phoenix.HTML.Form

  def humanize(%NaiveDateTime{} = datetime) do
    Timex.format!(datetime, gettext("{0M}/{0D}/{YYYY} {h12}:{m}{am}"))
  end

  def humanize(%DateTime{} = datetime) do
    Timex.format!(datetime, gettext("{0M}/{0D}/{YYYY} {h12}:{m}{am}"))
  end

  def humanize(%Date{} = date), do: Timex.format!(date, gettext("{0M}/{0D}/{YYYY}"))
  def humanize(true), do: gettext("Yes")
  def humanize(false), do: gettext("No")
  def humanize(atom) when is_atom(atom), do: Form.humanize(atom)
end
