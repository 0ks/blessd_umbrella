defmodule BlessdWeb.ConfirmationMailer do
  import Bamboo.Email
  import BlessdWeb.Gettext
  import EExHTML

  alias Blessd.Confirmation
  alias BlessdWeb.Mailer
  alias BlessdWeb.Router.Helpers, as: Routes

  def send(conn, user) do
    with {:ok, user} <- Confirmation.generate_token(user) do
      new_email()
      |> to(user.email)
      |> from("contact@blessd.app")
      |> subject(gettext("Welcome to Blessd - Email Confirmation"))
      |> html_body(email_html(conn, user))
      |> text_body(email_text(conn, user))
      |> Mailer.deliver_later()

      {:ok, user}
    end
  end

  defp email_html(conn, user) do
    ~E"""
    <h1><%= gettext("Welcome to Blessd, %{name}.", name: user.name) %></h1>

    <p>
      <a href="<%= confirmation_url(conn, user) %>">
        <%= gettext("Click here") %>
      </a>
      <%= gettext("to confirm your account") %>
    </p>

    <p>
      <%= gettext(
        "If the link does not work, copy this and paste on your localtion bar: %{url}",
        url: confirmation_url(conn, user)
      ) %>
    </p>
    """
  end

  defp email_text(conn, user) do
    ~E"""
    <%= gettext("Welcome to Blessd, %{name}.", name: user.name) %>

    <%= gettext(
      "Here is your confirmation link: %{url}",
      url: confirmation_url(conn, user)
    ) %>
    """
  end

  defp confirmation_url(conn, user) do
    Routes.confirmation_url(conn, :create, user.church.identifier, user.confirmation_token)
  end
end
