defmodule Blessd.Authentication.Session do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Authentication.Credential
  alias Blessd.Authentication.Session
  alias Blessd.Authentication.User
  alias Blessd.Repo

  embedded_schema do
    field(:church_identifier, :string)
    field(:email, :string)
    field(:password, :string)

    belongs_to(:church, Church)
    belongs_to(:user, User)
  end

  @doc false
  def changeset(%Session{} = session, attrs) do
    session
    |> cast(attrs, [:church_identifier, :email, :password])
    |> validate_required([:church_identifier, :email, :password])
    |> validate_church()
    |> validate_user()
  end

  defp validate_church(changeset) do
    with %Ecto.Changeset{valid?: true, changes: %{church_identifier: identifier}} <- changeset,
         {:ok, church} <- get_church(identifier) do
      put_assoc(changeset, :church, church)
    else
      %Ecto.Changeset{valid?: false} = changeset -> changeset
      {:error, :not_found} -> add_error(changeset, :church_identifier, "does not exist")
    end
  end

  defp validate_user(changeset) do
    with %Ecto.Changeset{
           valid?: true,
           changes: %{church: church, email: email, password: password}
         } <- changeset,
         {:ok, credential} <- get_credential(email, church),
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

  defp get_credential(email, %Ecto.Changeset{data: church}), do: get_credential(email, church)

  defp get_credential(email, %Church{id: church_id}) do
    Credential
    |> join(:left, [c], assoc(c, :user))
    |> where([c, u], u.church_id == ^church_id and u.email == ^email and c.source == "password")
    |> preload([c, u], user: u)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      credential -> {:ok, credential}
    end
  end

  defp get_church(identifier) do
    case Repo.get_by(Church, identifier: identifier) do
      nil -> {:error, :not_found}
      credential -> {:ok, credential}
    end
  end
end
