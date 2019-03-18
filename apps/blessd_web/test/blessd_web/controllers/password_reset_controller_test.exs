defmodule BlessdWeb.PasswordResetControllerTest do
  use BlessdWeb.ConnCase
  use Bamboo.Test

  import Ecto.Changeset

  alias Blessd.PasswordReset
  alias Blessd.Repo
  alias Blessd.Shared.Users.User, as: SharedUser

  describe "new password reset" do
    test "renders form", %{conn: conn} do
      conn =
        conn
        |> get(Routes.password_reset_path(conn, :new))

      assert html_response(conn, 200) =~ "Forgot my Password"
    end
  end

  describe "create password reset" do
    test "redirects to index when data is valid", %{conn: conn} do
      user = signup()

      resp =
        conn
        |> post(Routes.password_reset_path(conn, :create),
          token_data: %{email: user.email, church_slug: user.church.slug}
        )

      assert redirected_to(resp) == "/"
      assert_email_delivered_with(subject: "Reset your Blessd password")

      resp =
        conn
        |> authenticate(user)
        |> post(Routes.password_reset_path(conn, :create),
          user_id: user.id,
          church_slug: user.church.slug
        )

      assert redirected_to(resp) == Routes.user_path(conn, :edit, user.church.slug, user)
      assert_email_delivered_with(subject: "Reset your Blessd password")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> post(Routes.password_reset_path(conn, :create), token_data: %{email: nil})

      assert html_response(conn, 200) =~ "Forgot my Password"
    end
  end

  describe "edit password reset" do
    test "renders form for editing chosen church recovery", %{conn: conn} do
      user = signup()

      {:ok, %{password_reset_token: token}} =
        PasswordReset.generate_token(user.id, user.church.slug)

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.password_reset_path(conn, :edit, user.church.slug, token))

      assert html_response(conn, 200) =~ "Reset your password"
    end

    test "returns error when token not found or expired", %{conn: conn} do
      user = signup()

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.password_reset_path(conn, :edit, user.church.slug, "haisuodf"))

      assert redirected_to(resp) == Routes.password_reset_path(conn, :new)

      assert get_flash(resp, :error) ==
               "The given password reset token does not refer to any user."

      {:ok, new_user} = PasswordReset.generate_token(user.id, user.church.slug)
      expired_token = SharedUser.generate_token(-10)

      new_user
      |> change(%{password_reset_token: expired_token})
      |> Repo.update!()

      resp =
        conn
        |> get(Routes.password_reset_path(conn, :edit, user.church.slug, expired_token))

      assert redirected_to(resp) == Routes.password_reset_path(conn, :new)

      assert get_flash(resp, :error) ==
               "The given password reset token is invalid or expired, please request another email."
    end
  end

  describe "update password reset" do
    test "redirects when data is valid", %{conn: conn} do
      user = signup()

      {:ok, %{password_reset_token: token}} =
        PasswordReset.generate_token(user.id, user.church.slug)

      resp =
        conn
        |> authenticate(user)
        |> put(
          Routes.password_reset_path(conn, :update, user.church.slug, token),
          credential: %{
            source: "password",
            token: "new_password"
          }
        )

      assert redirected_to(resp) == Routes.dashboard_path(conn, :index, user.church.slug)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()

      {:ok, %{password_reset_token: token}} =
        PasswordReset.generate_token(user.id, user.church.slug)

      resp =
        conn
        |> authenticate(user)
        |> put(
          Routes.password_reset_path(conn, :update, user.church.slug, token),
          credential: %{
            source: "password",
            token: nil
          }
        )

      assert html_response(resp, 200) =~ "Reset your password"
    end
  end
end
