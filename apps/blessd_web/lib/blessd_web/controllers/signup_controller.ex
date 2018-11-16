defmodule BlessdWeb.SignupController do
  use BlessdWeb, :controller

  alias Blessd.Signup

  def new(conn, _params) do
    render(conn, "new.html", changeset: Signup.new_registration())
  end

  def create(conn, %{"registration" => registration_params}) do
    case Signup.register(registration_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, gettext("Signed up sucessfully"))
        |> redirect(to: Routes.person_path(conn, :index, user.church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
