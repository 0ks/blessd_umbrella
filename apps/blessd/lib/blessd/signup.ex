defmodule Blessd.Signup do
  @moduledoc """
  The Signup context.
  """

  import Ecto.Changeset, only: [apply_action: 2, put_assoc: 3]

  alias Blessd.Signup.Church
  alias Blessd.Signup.Credential
  alias Blessd.Signup.Registration
  alias Blessd.Signup.User
  alias Blessd.Repo
  alias Ecto.Multi

  @doc """
  Register the church, user and its credential.
  """
  def register(attrs) do
    Multi.new()
    |> Multi.run(:registration, &validate_registration(&1, &2, attrs))
    |> Multi.run(:church, &insert_church(&1, &2, attrs["church"]))
    |> Multi.run(:user, &insert_user(&1, &2, attrs["user"]))
    |> Multi.run(:credential, &insert_credential(&1, &2, attrs["credential"]))
    |> Repo.transaction()
    |> case do
      {:ok, %{church: church, user: user, credential: credential}} ->
        {:ok, %{user | church: church, credentials: [credential]}}

      {:error, :registration, changeset, _} ->
        {:error, changeset}

      {:error, assoc, child_changeset, %{registration: changeset}} ->
        changeset
        |> put_assoc(assoc, child_changeset)
        |> apply_action(:insert)
    end
  end

  defp validate_registration(_repo, _changes, attrs) do
    case Registration.changeset(%Registration{church: nil, user: nil, credential: nil}, attrs) do
      %Ecto.Changeset{valid?: true} = changeset -> {:ok, changeset}
      %Ecto.Changeset{valid?: false} = changeset -> apply_action(changeset, :insert)
    end
  end

  defp insert_church(repo, _changes, attrs) do
    %Church{}
    |> Church.changeset(attrs)
    |> repo.insert()
  end

  defp insert_user(repo, %{church: church}, attrs) do
    %User{church_id: church.id}
    |> User.changeset(attrs)
    |> repo.insert()
  end

  defp insert_credential(repo, %{church: church, user: user}, attrs) do
    %Credential{church_id: church.id, user_id: user.id}
    |> Credential.changeset(attrs)
    |> repo.insert()
  end

  @doc """
  Builds a credential to insert.
  """
  def new_registration do
    Registration.changeset(
      %Registration{
        church: %Church{},
        user: %User{},
        credential: %Credential{source: "password"}
      },
      %{}
    )
  end
end
