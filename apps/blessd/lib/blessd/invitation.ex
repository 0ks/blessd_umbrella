defmodule Blessd.Invitation do
  @moduledoc """
  The Invitation context.
  """

  import Blessd.Shared.Users.User
  import Ecto.Changeset

  alias Blessd.Shared
  alias Blessd.Invitation.Accept
  alias Blessd.Invitation.Credential
  alias Blessd.Invitation.User
  alias Blessd.Repo
  alias Ecto.Multi

  def invite(attrs, current_user) do
    with {:ok, user} <- new_user(current_user) do
      user
      |> User.invite_changeset(attrs)
      |> Repo.insert()
    end
  end

  def reinvite(token, current_user) do
    with {:ok, user} <- find_user(token, current_user) do
      user
      |> User.reinvite_changeset()
      |> Repo.update()
    end
  end

  def validate_token(token, slug) do
    with {:ok, user} <- find_user(token, slug) do
      user
      |> change(%{})
      |> validate_invitation()
      |> apply_action(:insert)
    end
  end

  def accept(token, attrs, slug) do
    with {:ok, user} <- find_user(token, slug),
         {:ok, credential} <- new_credential(user),
         {:ok, accept} <- new_accept(user, credential) do
      Multi.new()
      |> Multi.run(:accept, &validate_accept(&1, &2, accept, attrs))
      |> Multi.update(:user, User.accept_changeset(user, attrs["user"]))
      |> Multi.insert(:credential, Credential.changeset(credential, attrs["credential"]))
      |> Repo.transaction()
      |> case do
        {:ok, %{user: user}} ->
          {:ok, user}

        {:error, :accept, changeset, _} ->
          {:error, changeset}

        {:error, assoc, child_changeset, %{invitation: changeset}} ->
          changeset
          |> put_assoc(assoc, child_changeset)
          |> apply_action(:insert)
      end
    end
  end

  defp validate_accept(_repo, _changes, accept, attrs) do
    case Accept.changeset(accept, attrs) do
      %Ecto.Changeset{valid?: true} = changeset -> {:ok, changeset}
      %Ecto.Changeset{valid?: false} = changeset -> apply_action(changeset, :insert)
    end
  end

  def new_accept(user) do
    with {:ok, credential} <- new_credential(user), do: new_accept(user, credential)
  end

  def new_accept(user, credential), do: {:ok, %Accept{user: user, credential: credential}}

  def change_accept(accept), do: {:ok, Accept.changeset(accept, %{})}

  def new_user(current_user) do
    authorize(
      %User{church_id: current_user.church_id, church: current_user.church},
      :new,
      current_user
    )
  end

  def change_user(user, current_user) do
    with {:ok, user} <- authorize(user, :change, current_user) do
      {:ok, User.invite_changeset(user, %{})}
    end
  end

  defp new_credential(user) do
    {:ok, %Credential{church_id: user.church_id, user_id: user.id, source: "password"}}
  end

  def change_credential(credential, current_user) do
    with {:ok, credential} <- authorize(credential, :change, current_user) do
      {:ok, Credential.changeset(credential, %{})}
    end
  end

  defp find_user(token, slug) when is_binary(slug) do
    with {:ok, church} <- Shared.find_church(slug), do: find_user(token, church)
  end

  defp find_user(token, church_or_user) do
    with {:ok, query} <- authorize(User, :find, church_or_user) do
      query
      |> User.preload()
      |> Repo.find_by(invitation_token: token)
    end
  end

  @doc """
  Sharedorizes the given resource. If authorized, it returns
  `{:ok, resource}`, otherwise, returns `{:error, reason}`,
  """
  def authorize(User, _action, church_or_user), do: Shared.authorize(User, church_or_user)

  def authorize(%User{} = user, _action, current_user), do: Shared.authorize(user, current_user)

  def authorize(%Credential{} = credential, _action, current_user) do
    Shared.authorize(credential, current_user)
  end

  @doc """
  Returns `true` if the given current_user is authorized
  to do the given action to the resource.
  """
  def authorized?(resource, action, current_user) do
    case authorize(resource, action, current_user) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
