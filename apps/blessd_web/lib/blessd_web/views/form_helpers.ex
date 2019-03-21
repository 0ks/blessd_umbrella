defmodule BlessdWeb.FormHelpers do
  alias Phoenix.HTML.Form
  alias Phoenix.HTML.Tag
  alias Blessd.Shared
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

  def select(form, field, select_opts, opts \\ []) do
    {input_opts, wrapper_opts} = Keyword.pop(opts, :input, [])
    select = Form.select(form, field, select_opts, input_opts)
    wrapper_opts = handle_input_opts(form, field, "select is-fullwidth", wrapper_opts)
    Tag.content_tag(:div, select, wrapper_opts)
  end

  defp handle_input_opts(form, field, default_class, opts) do
    default_class = handle_default_class(form, field, default_class)

    old_class =
      opts
      |> Keyword.get_values(:class)
      |> Enum.join(" ")

    Keyword.put(opts, :class, "#{default_class} #{old_class}")
  end

  defp handle_default_class(form, field, default_class) do
    if ErrorHelpers.has_errors?(form, field) do
      "#{default_class} is-danger"
    else
      default_class
    end
  end

  def custom_data_fields(form, func) do
    resource = form.source.data

    changeset =
      case form.source.changes[:custom_data] do
        %Ecto.Changeset{} = changeset ->
          %{changeset | action: form.source.action}

        changes ->
          Shared.custom_data_changeset(
            form.name,
            resource.custom_data,
            changes || %{},
            resource.church_id
          )
      end

    func.(%Phoenix.HTML.Form{
      source: changeset,
      impl: __MODULE__,
      id: "#{form.id}_custom_data",
      name: "#{form.name}[custom_data]",
      errors: custom_data_fields_errors(changeset),
      data: changeset.data,
      params: changeset.params || %{},
      hidden: [],
      options: []
    })
  end

  defp custom_data_fields_errors(%{action: nil}), do: []
  defp custom_data_fields_errors(%{action: :ignore}), do: []
  defp custom_data_fields_errors(%{errors: errors}), do: errors
end
