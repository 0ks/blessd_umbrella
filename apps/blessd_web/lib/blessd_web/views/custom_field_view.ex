defmodule BlessdWeb.CustomFieldView do
  use BlessdWeb, :view

  alias Blessd.Custom.Fields.Field
  alias BlessdWeb.SharedView

  def type_options do
    Enum.map(Field.valid_types(), &{translate_type(&1), &1})
  end

  def translate_type(type) do
    Gettext.dgettext(BlessdWeb.Gettext, "field_types", type)
  end
end

