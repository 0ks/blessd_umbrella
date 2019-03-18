defmodule BlessdWeb.ConfirmationControllerTest do
  use BlessdWeb.ConnCase
  use Bamboo.Test

  import Ecto.Changeset

  alias Blessd.Repo
  alias Blessd.Signup
  alias Blessd.Confirmation.User
  alias Blessd.Shared.Users.User, as: SharedUser

  describe "create confirmation" do
    test "creates the confirmation and redirects to dashboard", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.confirmation_path(conn, :create, user.church.slug))

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index, user.church.slug)
      assert get_flash(conn, :info) == "Confirmation email sent."
      assert_email_delivered_with(subject: "Welcome to Blessd - email confirmation")
    end
  end

  @signup_attrs %{
    "church" => %{name: "Test Church", slug: "test_church", timezone: "UTC"},
    "user" => %{name: "Test User", email: "test_user@mail.com"},
    "credential" => %{source: "password", token: "password"}
  }

  describe "show confirmation" do
    test "confirms the user email", %{conn: conn} do
      {:ok, user} = Signup.register(@signup_attrs)

      conn =
        conn
        |> get(Routes.confirmation_path(conn, :show, user.church.slug, user.confirmation_token))

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index, user.church.slug)
      assert get_flash(conn, :info) == "Email confirmed successfully."
    end

    test "returns error when token not found or expired", %{conn: conn} do
      user = signup()

      resp =
        conn
        |> get(Routes.confirmation_path(conn, :show, user.church.slug, "haosudhfuiasdf"))

      assert redirected_to(resp) == "/"
      assert get_flash(resp, :error) == "The given confirmation token does not refer to any user."

      expired_token = SharedUser.generate_token(-10)

      User
      |> Repo.get(user.id)
      |> change(%{confirmation_token: expired_token})
      |> Repo.update!()

      resp =
        conn
        |> get(Routes.confirmation_path(conn, :show, user.church.slug, expired_token))

      assert redirected_to(resp) == "/"

      assert get_flash(resp, :error) ==
               "The given confirmation token is invalid or expired,\nplease request another confirmation email.\n"
    end
  end
end
