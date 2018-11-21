defmodule BlessdWeb.ConfirmationMailer do
  import Bamboo.Email
  import BlessdWeb.Gettext
  import EExHTML

  alias BlessdWeb.Endpoint
  alias BlessdWeb.Mailer
  alias BlessdWeb.Router.Helpers, as: Routes

  def send(user) do
    new_email()
    |> to(user.email)
    |> from("contact@blessd.app")
    |> subject(gettext("Welcome to Blessd - email confirmation"))
    |> html_body(email_html(user))
    |> text_body(email_text(user))
    |> Mailer.deliver_later()

    :ok
  end

  defp email_html(user) do
    to_string(~E"""
    <h1><%= gettext("Welcome to Blessd, %{name}.", name: user.name) %></h1>

    <p>
      <a href="<%= confirmation_url(user) %>"><%= gettext("Click here") %></a>

      <%= gettext("to confirm your account") %>
    </p>

    <p>
      <%= gettext(
        "If the link does not work, copy this and paste on your localtion bar: %{url}",
        url: confirmation_url(user)
      ) %>
    </p>
    """)
  end

  defp email_text(user) do
    to_string(~E"""
    <%= gettext("Welcome to Blessd, %{name}.", name: user.name) %>

    <%= gettext(
      "Here is your confirmation link: %{url}",
      url: confirmation_url(user)
    ) %>
    """)
  end

  defp confirmation_url(user) do
    Routes.confirmation_url(Endpoint, :show, user.church.identifier, user.confirmation_token)
  end
end
