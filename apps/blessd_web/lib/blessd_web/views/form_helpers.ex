defmodule BlessdWeb.FormHelpers do
  alias Phoenix.HTML.Form
  alias BlessdWeb.ErrorHelpers

  def form_action(:create, _, route_helper), do: route_helper.(:create, [])
  def form_action(:update, changeset, route_helper), do: route_helper.(:update, changeset.data)

  def date_input(form, field, opts \\ []) do
    Form.date_input(form, field, handle_input_opts(form, field, "input", opts))
  end

  def text_input(form, field, opts \\ []) do
    Form.text_input(form, field, handle_input_opts(form, field, "input", opts))
  end

  def password_input(form, field, opts \\ []) do
    Form.password_input(form, field, handle_input_opts(form, field, "input", opts))
  end

  def textarea(form, field, opts \\ []) do
    Form.textarea(form, field, handle_input_opts(form, field, "textarea", opts))
  end

  defp handle_input_opts(form, field, default_class, opts) do
    default_class =
      if ErrorHelpers.has_errors?(form, field) do
        "#{default_class} is-danger"
      else
        default_class
      end

    old_class =
      opts
      |> Keyword.get_values(:class)
      |> Enum.join(" ")

    Keyword.put(opts, :class, "#{default_class} #{old_class}")
  end
end
