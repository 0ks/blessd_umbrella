defmodule BlessdWeb.ImportControllerTest do
  use BlessdWeb.ConnCase

  @create_attrs %{
    people: %Plug.Upload{
      path: Path.expand("test/fixtures/valid_import_people.csv"),
      filename: "valid_import_people.csv"
    }
  }
  @invalid_attrs %{
    people: %Plug.Upload{
      path: Path.expand("test/fixtures/invalid_import_people.csv"),
      filename: "invalid_import_people.csv"
    }
  }

  describe "import people" do
    test "redirects to index when data is valid", %{conn: conn} do
      church = auth_church()
      conn = post(conn, import_path(conn, :create, church.identifier), import: @create_attrs)
      assert redirected_to(conn) == person_path(conn, :index, church.identifier)
      assert get_flash(conn, :info) == "People imported successfully."
    end

    test "renders errors when data is invalid", %{conn: conn} do
      church = auth_church()
      conn = post(conn, import_path(conn, :create, church.identifier), import: @invalid_attrs)
      assert redirected_to(conn) == person_path(conn, :index, church.identifier)
      assert get_flash(conn, :error) == "Sorry! The file provided could not be imported."

      details =
        conn
        |> get_flash(:error_details)
        |> Phoenix.HTML.html_escape()
        |> Phoenix.HTML.safe_to_string()

      assert details =~ "The person of the line #3 could not be created."
    end
  end
end
