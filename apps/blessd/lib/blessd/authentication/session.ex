defmodule Blessd.Authentication.Session do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Churches.Church
  alias Blessd.Authentication.Credential
  alias Blessd.Authentication.Session
  alias Blessd.Authentication.User
  alias Blessd.Repo

  embedded_schema do
    field(:church_slug, :string)
    field(:email, :string)
    field(:password, :string)

    belongs_to(:church, Church)
    belongs_to(:user, User)
  end

  @doc false
  def changeset(%Session{} = session, attrs) do
    session
    |> cast(attrs, [:church_slug, :email, :password])
    |> validate_required([:church_slug, :email, :password])
    |> validate_church()
    |> validate_user()
  end

  defp validate_church(changeset) do
    with %Ecto.Changeset{valid?: true, changes: %{church_slug: slug}} <- changeset,
         {:ok, church} <- Repo.find_by(Church, slug: slug) do
      put_assoc(changeset, :church, church)
    else
      %Ecto.Changeset{valid?: false} = changeset -> changeset
      {:error, :not_found} -> add_error(changeset, :church_slug, "does not exist")
    end
  end

  defp validate_user(changeset) do
    with %Ecto.Changeset{
           valid?: true,
           changes: %{church: church, email: email, password: password}
         } <- changeset,
         {:ok, credential} <- find_credential(email, church),
         true <- Comeonin.Bcrypt.checkpw(password, credential.token) do
      put_assoc(changeset, :user, credential.user)
    else
      %Ecto.Changeset{valid?: false} = changeset ->
        changeset

      {:error, :not_found} ->
        Comeonin.Bcrypt.dummy_checkpw()
        add_error(changeset, :password, "does not match")

      false ->
        add_error(changeset, :password, "does not match")
    end
  end

  defp find_credential(email, %Ecto.Changeset{data: church}), do: find_credential(email, church)

  defp find_credential(email, %Church{id: church_id}) do
    Credential
    |> join(:left, [c], assoc(c, :user))
    |> where([c, u], u.church_id == ^church_id and u.email == ^email and c.source == "password")
    |> preload([c, u], user: u)
    |> Repo.single()
  end
end
