defmodule BlessdWeb.FormHelpers do
  alias Phoenix.HTML.Form
  alias BlessdWeb.ErrorHelpers

  def form_action(:create, _, route_helper), do: route_helper.(:create, [])
  def form_action(:update, changeset, route_helper), do: route_helper.(:update, changeset.data)

  def date_input(form, field, opts \\ []) do
    Form.date_input(form, field, handle_input_opts(form, field, opts))
  end

  def text_input(form, field, opts \\ []) do
    Form.text_input(form, field, handle_input_opts(form, field, opts))
  end

  def password_input(form, field, opts \\ []) do
    Form.password_input(form, field, handle_input_opts(form, field, opts))
  end

  defp handle_input_opts(form, field, opts) do
    default_class = default_input_class(form, field)

    old_class =
      opts
      |> Keyword.get_values(:class)
      |> Enum.join(" ")

    Keyword.put(opts, :class, "#{default_class} #{old_class}")
  end

  defp default_input_class(form, field) do
    if ErrorHelpers.has_errors?(form, field) do
      "input is-danger"
    else
      "input"
    end
  end
end
