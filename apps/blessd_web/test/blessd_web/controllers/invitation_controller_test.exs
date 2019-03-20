defmodule BlessdWeb.InvitationControllerTest do
  use BlessdWeb.ConnCase
  use Bamboo.Test

  import Ecto.Changeset

  alias Blessd.Invitation
  alias Blessd.Repo
  alias Blessd.Shared.Users.User, as: SharedUser

  @create_attrs %{email: "some@email.com"}
  @invalid_attrs %{email: nil}

  describe "new invitation" do
    test "renders form", %{conn: conn} do
      user = signup()

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.invitation_path(conn, :new, user.church.slug))

      assert html_response(conn, 200) =~ "Invite User"
    end
  end

  describe "create invitation" do
    test "redirects to index when data is valid", %{conn: conn} do
      user = signup()

      resp =
        conn
        |> authenticate(user)
        |> post(Routes.invitation_path(conn, :create, user.church.slug), user: @create_attrs)

      assert redirected_to(resp) == Routes.user_path(conn, :index, user.church.slug)
      assert_email_delivered_with(subject: "You were invited to Blessd")

      {:ok, %{invitation_token: token}} = Invitation.invite(%{email: "reinvite@mail.com"}, user)

      resp =
        conn
        |> authenticate(user)
        |> post(Routes.invitation_path(conn, :create, user.church.slug), token: token)

      assert redirected_to(resp) == Routes.user_path(conn, :index, user.church.slug)
      assert_email_delivered_with(subject: "You were invited to Blessd")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()

      resp =
        conn
        |> authenticate(user)
        |> post(Routes.invitation_path(conn, :create, user.church.slug), user: @invalid_attrs)

      assert html_response(resp, 200) =~ "Invite User"

      resp =
        conn
        |> authenticate(user)
        |> post(Routes.invitation_path(conn, :create, user.church.slug), token: "jaisudhfiodofi")

      assert resp.status == 404
    end
  end

  describe "edit invitation" do
    test "renders form for editing chosen person", %{conn: conn} do
      user = signup()
      {:ok, %{invitation_token: token}} = Invitation.invite(%{email: "reinvite@mail.com"}, user)

      resp =
        conn
        |> get(Routes.invitation_path(conn, :edit, user.church.slug, token))

      assert html_response(resp, 200) =~ "Accepting Invitation"
    end

    test "returns error when token not found or expired", %{conn: conn} do
      user = signup()

      resp =
        conn
        |> authenticate(user)
        |> get(Routes.invitation_path(conn, :edit, user.church.slug, "haisuodf"))

      assert redirected_to(resp) == "/"
      assert get_flash(resp, :error) == "The given invitation token does not refer to any user."

      {:ok, new_user} = Invitation.invite(%{email: "reinvite@mail.com"}, user)
      expired_token = SharedUser.generate_token(-10)

      new_user
      |> change(%{invitation_token: expired_token})
      |> Repo.update!()

      resp =
        conn
        |> get(Routes.invitation_path(conn, :edit, user.church.slug, expired_token))

      assert redirected_to(resp) == "/"

      assert get_flash(resp, :error) ==
               "The given invitation token is invalid or expired,\nplease request another invitation email.\n"
    end
  end

  describe "update person" do
    test "redirects when data is valid", %{conn: conn} do
      user = signup()
      {:ok, %{invitation_token: token}} = Invitation.invite(%{email: "reinvite@mail.com"}, user)

      resp =
        conn
        |> put(Routes.invitation_path(conn, :update, user.church.slug, token),
          accept: %{
            user: %{name: "John"},
            credential: %{source: "password", token: "password"}
          }
        )

      assert redirected_to(resp) == Routes.dashboard_path(conn, :index, user.church.slug)
      assert get_flash(resp, :info) == "Invitation accepted succesfully."
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = signup()
      {:ok, %{invitation_token: token}} = Invitation.invite(%{email: "reinvite@mail.com"}, user)

      conn =
        conn
        |> put(Routes.invitation_path(conn, :update, user.church.slug, token),
          accept: %{
            user: %{name: nil},
            credential: %{source: "password", token: nil}
          }
        )

      assert html_response(conn, 200) =~ "Accepting Invitation"
    end
  end
end
