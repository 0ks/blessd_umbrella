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
    |> Multi.run(:registration, &validate_registration(attrs, &1))
    |> Multi.run(:church, &insert_church(attrs["church"], &1))
    |> Multi.run(:user, &insert_user(attrs["user"], &1))
    |> Multi.run(:credential, &insert_credential(attrs["credential"], &1))
    |> Repo.transaction()
    |> case do
      {:ok, %{church: church, user: user, credential: credential}} ->
        {:ok, %{church: church, user: %{user | credentials: [credential]}}}

      {:error, :registration, changeset, _} ->
        {:error, changeset}

      {:error, :church, child_changeset, %{registration: changeset}} ->
        put_assoc_error(changeset, child_changeset, :church)

      {:error, :user, child_changeset, %{registration: changeset}} ->
        put_assoc_error(changeset, child_changeset, :user)

      {:error, :credential, child_changeset, %{registration: changeset}} ->
        put_assoc_error(changeset, child_changeset, :credential)
    end
  end

  defp put_assoc_error(changeset, child_changeset, assoc) do
    changeset
    |> put_assoc(assoc, child_changeset)
    |> apply_action(:insert)
  end

  defp validate_registration(attrs, _changes) do
    case Registration.changeset(%Registration{church: nil, user: nil, credential: nil}, attrs) do
      %Ecto.Changeset{valid?: true} = changeset -> {:ok, changeset}
      %Ecto.Changeset{valid?: false} = changeset -> apply_action(changeset, :insert)
    end
  end

  defp insert_church(attrs, _changes) do
    %Church{}
    |> Church.changeset(attrs)
    |> Repo.insert()
  end

  defp insert_user(attrs, %{church: church}) do
    %User{church_id: church.id}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  defp insert_credential(attrs, %{church: church, user: user}) do
    %Credential{church_id: church.id, user_id: user.id}
    |> Credential.changeset(attrs)
    |> Repo.insert()
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
