defmodule GolgothaWeb.PersonController do
  use GolgothaWeb, :controller

  alias Golgotha.Memberships
  alias Golgotha.Memberships.Person

  def index(conn, _params) do
    people = Memberships.list_people()
    render(conn, "index.html", people: people)
  end

  def new(conn, _params) do
    changeset = Memberships.change_person(%Person{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"person" => person_params}) do
    case Memberships.create_person(person_params) do
      {:ok, person} ->
        conn
        |> put_flash(:info, "Person created successfully.")
        |> redirect(to: person_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    person = Memberships.get_person!(id)
    changeset = Memberships.change_person(person)
    render(conn, "edit.html", person: person, changeset: changeset)
  end

  def update(conn, %{"id" => id, "person" => person_params}) do
    person = Memberships.get_person!(id)

    case Memberships.update_person(person, person_params) do
      {:ok, person} ->
        conn
        |> put_flash(:info, "Person updated successfully.")
        |> redirect(to: person_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", person: person, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    person = Memberships.get_person!(id)
    {:ok, _person} = Memberships.delete_person(person)

    conn
    |> put_flash(:info, "Person deleted successfully.")
    |> redirect(to: person_path(conn, :index))
  end
end
