defmodule BlessdWeb.PersonController do
  use BlessdWeb, :controller

  alias Blessd.Memberships

  def index(conn, _params) do
    people = Memberships.list_people(conn.assigns.current_user)
    render(conn, "index.html", people: people)
  end

  def new(conn, _params) do
    user = conn.assigns.current_user

    changeset =
      user
      |> Memberships.new_person()
      |> Memberships.change_person(user)

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"person" => person_params}) do
    user = conn.assigns.current_user

    case Memberships.create_person(person_params, user) do
      {:ok, _person} ->
        conn
        |> put_flash(:info, gettext("Person created successfully."))
        |> redirect(to: person_path(conn, :index, user.church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    changeset =
      id
      |> Memberships.get_person!(user)
      |> Memberships.change_person(user)

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "person" => person_params}) do
    user = conn.assigns.current_user
    person = Memberships.get_person!(id, user)

    case Memberships.update_person(person, person_params, user) do
      {:ok, _person} ->
        conn
        |> put_flash(:info, gettext("Person updated successfully."))
        |> redirect(to: person_path(conn, :index, user.church.identifier))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    person = Memberships.get_person!(id, user)
    {:ok, _person} = Memberships.delete_person(person, user)

    conn
    |> put_flash(:info, gettext("Person deleted successfully."))
    |> redirect(to: person_path(conn, :index, user.church.identifier))
  end
end
