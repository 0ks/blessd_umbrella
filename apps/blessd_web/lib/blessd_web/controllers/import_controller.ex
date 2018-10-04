defmodule BlessdWeb.ImportController do
  use BlessdWeb, :controller

  import Phoenix.HTML.Tag

  alias Blessd.Memberships
  alias BlessdWeb.ErrorHelpers

  def create(conn, %{"import" => %{"people" => file}}) do
    file.path
    |> File.stream!()
    |> Memberships.create_people()
    |> case do
      {:ok, _people} ->
        conn
        |> put_flash(:info, "People imported successfully.")
        |> redirect(to: person_path(conn, :index))

      {:error, line, changeset} ->
        conn
        |> put_flash(:error, "Sorry! The file provided could not be imported.")
        |> put_flash(:error_details, create_error_details(line, changeset))
        |> redirect(to: person_path(conn, :index))
    end
  end

  defp create_error_details(line, changeset) do
    error_tags =
      changeset
      |> ErrorHelpers.list_errors()
      |> Enum.map(&content_tag(:li, &1))

    [
      content_tag(:p, "The person of the line ##{line} could not be imported."),
      content_tag(:p, "Here is the list of errors:"),
      content_tag(:ul, error_tags)
    ]
  end
end
