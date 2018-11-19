defmodule BlessdWeb.SignupController do
  use BlessdWeb, :controller

  alias Blessd.Signup
  alias BlessdWeb.ConfirmationMailer

  def new(conn, _params) do
    render(conn, "new.html", changeset: Signup.new_registration())
  end

  def create(conn, %{"registration" => registration_params}) do
    with {:ok, user} <- Signup.register(registration_params),
         {:ok, user} = ConfirmationMailer.send(user) do
      conn
      |> put_session(:current_user_id, user.id)
      |> put_flash(:info, gettext("Signed up sucessfully"))
      |> redirect(to: Routes.person_path(conn, :index, user.church.identifier))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
