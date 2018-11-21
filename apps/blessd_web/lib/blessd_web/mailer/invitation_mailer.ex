defmodule BlessdWeb.InvitationMailer do
  import Bamboo.Email
  import BlessdWeb.Gettext
  import EExHTML

  alias BlessdWeb.Endpoint
  alias BlessdWeb.Mailer
  alias BlessdWeb.Router.Helpers, as: Routes

  def send(user, inviter) do
    new_email()
    |> to(user.email)
    |> from("contact@blessd.app")
    |> subject(gettext("You were invited to Blessd"))
    |> html_body(email_html(user, inviter))
    |> text_body(email_text(user, inviter))
    |> Mailer.deliver_later()

    :ok
  end

  defp email_html(user, inviter) do
    to_string(~E"""
    <h1><%= gettext("%{name} invited you to Blessd!", name: inviter.name) %></h1>

    <p>
      <a href="<%= invitation_url(user) %>"><%= gettext("Click here") %></a>

      <%= gettext("to accept the invitation") %>
    </p>

    <p>
      <%= gettext(
        "If the link does not work, copy this and paste on your localtion bar: %{url}",
        url: invitation_url(user)
      ) %>
    </p>
    """)
  end

  defp email_text(user, inviter) do
    to_string(~E"""
    <%= gettext("%{name} invited you to Blessd!", name: inviter.name) %>

    <%= gettext(
      "Here is your invitation link: %{url}",
      url: invitation_url(user)
    ) %>
    """)
  end

  defp invitation_url(user) do
    Routes.invitation_url(Endpoint, :edit, user.church.identifier, user.invitation_token)
  end
end
