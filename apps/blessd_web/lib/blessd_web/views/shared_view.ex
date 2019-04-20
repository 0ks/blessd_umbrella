defmodule BlessdWeb.SharedView do
  use BlessdWeb, :view

  alias Blessd.Shared

  def languages_for_select do
    for language <- Shared.languages() do
      {Gettext.dgettext(BlessdWeb.Gettext, "languages", language), language}
    end
  end
end
