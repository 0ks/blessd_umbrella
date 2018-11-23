defmodule BlessdWeb.ChurchRecoveryMailer do
  import Bamboo.Email
  import BlessdWeb.Gettext
  import EExHTML

  alias BlessdWeb.Endpoint
  alias BlessdWeb.Mailer
  alias BlessdWeb.Router.Helpers, as: Routes

  def send(credential) do
    new_email()
    |> to(credential.user.email)
    |> from("contact@blessd.app")
    |> subject(gettext("Reset your Blessd password"))
    |> html_body(email_html(credential))
    |> text_body(email_text(credential))
    |> Mailer.deliver_later()

    :ok
  end

  defp email_html(credential) do
    to_string(~E"""
    <h1><%= gettext("Forgot your church URL, %{name}?", name: credential.user.name) %></h1>

    <p>
      <a href="<%= password_reset_url(credential) %>"><%= gettext("Click here") %></a>

      <%= gettext("and you will be able to find it again") %>
    </p>

    <p>
      <%= gettext(
        "If the link does not work, copy this and paste on your localtion bar: %{url}",
        url: password_reset_url(credential)
      ) %>
    </p>
    """)
  end

  defp email_text(credential) do
    to_string(~E"""
    <%= gettext("Forgot your church URL, %{name}?", name: credential.user.name) %>

    <%= gettext(
      "Here is your church recovery link: %{url}",
      url: password_reset_url(credential)
    ) %>
    """)
  end

  defp password_reset_url(credential) do
    Routes.church_recovery_path(Endpoint, :edit, credential.token)
  end
end
