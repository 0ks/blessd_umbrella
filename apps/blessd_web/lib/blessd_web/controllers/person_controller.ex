defmodule BlessdWeb.PersonController do
  use BlessdWeb, :controller

  alias Blessd.Memberships

  def index(conn, _params) do
    people = Memberships.list_people(conn.assigns.current_church)
    render(conn, "index.html", people: people)
  end

  def new(conn, _params) do
    church = conn.assigns.current_church

    changeset =
      church
      |> Memberships.new_person()
      |> Memberships.change_person(church)

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"person" => person_params}) do
    church = conn.assigns.current_church

    case Memberships.create_person(person_params, church) do
      {:ok, _person} ->
        conn
        |> put_flash(:info, gettext("Person created successfully."))
        |> redirect(to: person_path(conn, :index, church))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    church = conn.assigns.current_church

    changeset =
      id
      |> Memberships.get_person!(church)
      |> Memberships.change_person(church)

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "person" => person_params}) do
    church = conn.assigns.current_church
    person = Memberships.get_person!(id, church)

    case Memberships.update_person(person, person_params, church) do
      {:ok, _person} ->
        conn
        |> put_flash(:info, gettext("Person updated successfully."))
        |> redirect(to: person_path(conn, :index, church))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    church = conn.assigns.current_church
    person = Memberships.get_person!(id, church)
    {:ok, _person} = Memberships.delete_person(person, church)

    conn
    |> put_flash(:info, gettext("Person deleted successfully."))
    |> redirect(to: person_path(conn, :index, church))
  end
end
