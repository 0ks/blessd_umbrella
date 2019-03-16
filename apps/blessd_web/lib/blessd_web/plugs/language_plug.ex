defmodule BlessdWeb.LanguagePlug do
  alias Blessd.Shared

  def init(opts), do: opts

  def call(conn, _opts) do
    valid_languages = Shared.languages()

    fallback = case conn.assigns[:current_user] do
      nil -> Shared.default_language()
      user -> user.church.language
    end

    language =
      conn
      |> PlugAcceptLanguage.list()
      |> Stream.map(&String.replace(&1, "-", "_"))
      |> Stream.map(&String.downcase/1)
      |> Enum.find(fallback, &(&1 in valid_languages))

    Gettext.put_locale(BlessdWeb.Gettext, language)

    conn
  end
end

