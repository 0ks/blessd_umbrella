defmodule BlessdWeb.ImportController do
  use BlessdWeb, :controller

  import Phoenix.HTML.Tag

  alias Blessd.Memberships
  alias BlessdWeb.ErrorHelpers

  def create(conn, %{"import" => %{"people" => file}}) do
    user = conn.assigns.current_user

    file.path
    |> File.stream!()
    |> Memberships.import_people(user)
    |> case do
      {:ok, _people} ->
        conn
        |> put_flash(:info, gettext("People imported successfully."))
        |> redirect(to: Routes.person_path(conn, :index, user.church.identifier))

      {:error, line, changeset} ->
        conn
        |> put_flash(:error, gettext("Sorry! The file provided could not be imported."))
        |> put_flash(:error_details, create_error_details(line, changeset))
        |> redirect(to: Routes.person_path(conn, :index, user.church.identifier))

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_error_details(line, changeset) do
    error_tags =
      changeset
      |> ErrorHelpers.list_errors()
      |> Enum.map(&content_tag(:li, &1))

    [
      content_tag(
        :p,
        gettext("The person of the line #%{line} could not be created.", line: line)
      ),
      content_tag(:p, gettext("Here is the list of errors:")),
      content_tag(:ul, error_tags)
    ]
  end
end
