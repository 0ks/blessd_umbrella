defmodule BlessdWeb.PasswordResetMailer do
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
    |> subject(gettext("Reset your Blessd password"))
    |> html_body(email_html(user))
    |> text_body(email_text(user))
    |> Mailer.deliver_later()

    :ok
  end

  defp email_html(user) do
    to_string(~E"""
    <h1><%= gettext("Forgot your password, %{name}?", name: user.name) %></h1>

    <p>
      <a href="<%= password_reset_url(user) %>"><%= gettext("Click here") %></a>

      <%= gettext("to reset it") %>
    </p>

    <p>
      <%= gettext(
        "If the link does not work, copy this and paste on your localtion bar: %{url}",
        url: password_reset_url(user)
      ) %>
    </p>
    """)
  end

  defp email_text(user) do
    to_string(~E"""
    <%= gettext("Forgot your password, %{name}?", name: user.name) %>

    <%= gettext(
      "Here is your password reset link: %{url}",
      url: password_reset_url(user)
    ) %>
    """)
  end

  defp password_reset_url(user) do
    Routes.password_reset_url(Endpoint, :edit, user.church.slug, user.password_reset_token)
  end
end
