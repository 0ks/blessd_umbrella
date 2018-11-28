defmodule BlessdWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  require BlessdWeb.Gettext

  @doc """
  Generates tag for form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:p, translate_error(error), class: "help is-danger")
    end)
  end

  def error_alert(form) do
    if has_errors?(form) do
      error_message =
        BlessdWeb.Gettext.gettext("""
        Oops, something went wrong! Please check the errors below.
        """)

      content_tag :div, class: "message is-danger" do
        content_tag(:div, error_message, class: "message-body")
      end
    end
  end

  def list_errors(%Ecto.Changeset{errors: errors}) do
    for {field, error} <- errors do
      case field do
        :base ->
          error
          |> translate_error()
          |> String.capitalize()

        field ->
          String.capitalize("#{humanize(field)} #{translate_error(error)}")
      end
    end
  end

  def has_errors?(%Phoenix.HTML.Form{} = form) do
    form.errors != [] || has_errors?(form.source)
  end

  def has_errors?(%Ecto.Changeset{valid?: false, action: action}) when action != nil do
    true
  end

  def has_errors?(%Ecto.Changeset{changes: changes}) do
    changes
    |> Enum.map(&elem(&1, 1))
    |> List.flatten()
    |> Enum.any?(fn
      %Ecto.Changeset{} = changeset -> has_errors?(changeset)
      _ -> false
    end)
  end

  def has_errors?(_), do: false

  def has_errors?(form, field) do
    Keyword.get_values(form.errors, field) != []
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext "errors", "is invalid"
    #
    #     # Translate the number of files with plural rules
    #     dngettext "errors", "1 file", "%{count} files", count
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(BlessdWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(BlessdWeb.Gettext, "errors", msg, opts)
    end
  end
end
