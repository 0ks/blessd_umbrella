defmodule Blessd.PasswordReset do
  @moduledoc """
  The PasswordReset context.
  """

  import Ecto.Changeset
  import Blessd.Changeset.User

  alias Blessd.Auth
  alias Blessd.PasswordReset.Credential
  alias Blessd.PasswordReset.User
  alias Blessd.PasswordReset.TokenData
  alias Blessd.Repo
  alias Ecto.Multi

  def generate_token(attrs) do
    with {:ok, user} <- find_user_by_email(attrs["email"], attrs["church_slug"]) do
      Multi.new()
      |> Multi.run(:token_data, &validate_token_data(&1, &2, attrs))
      |> Multi.update(:user, User.token_changeset(user))
      |> Repo.transaction()
      |> case do
        {:ok, %{user: user}} ->
          {:ok, user}

        {:error, :token_data, changeset, _} ->
          {:error, changeset}

        {:error, :user, _, _} ->
          {:error, :token_not_generated}
      end
    end
  end

  def validate_token_data(_repo, _changes, attrs) do
    case TokenData.changeset(%TokenData{church_slug: nil, email: nil}, attrs) do
      %Ecto.Changeset{valid?: true} = changeset -> {:ok, changeset}
      %Ecto.Changeset{valid?: false} = changeset -> apply_action(changeset, :insert)
    end
  end

  def new_token_data, do: {:ok, %TokenData{church_slug: nil, email: nil}}

  def change_token_data(token_data), do: {:ok, TokenData.changeset(token_data, %{})}

  def validate_token(token, slug) do
    with {:ok, user} <- find_user_by_token(token, slug) do
      user
      |> change(%{})
      |> validate_password_reset()
      |> apply_action(:insert)
    end
  end

  def reset(token, attrs, slug) do
    with {:ok, user} <- find_user_by_token(token, slug),
         {:ok, credential} <- find_credential(user) do
      credential
      |> Credential.changeset(attrs)
      |> Repo.update()
    end
  end

  def find_credential(user) do
    Credential
    |> Credential.password()
    |> Credential.by_user(user)
    |> Credential.preload()
    |> Repo.single()
  end

  def change_credential(credential), do: {:ok, Credential.changeset(credential, %{})}

  defp find_user_by_token(token, slug) when is_binary(slug) do
    with_church(slug, &find_user_by_token(token, &1))
  end

  defp find_user_by_token(token, church_or_user) do
    with {:ok, query} <- authorize(User, :find, church_or_user) do
      query
      |> User.by_token(token)
      |> User.preload()
      |> Repo.single()
    end
  end

  defp find_user_by_email(email, slug) when is_binary(slug) do
    with_church(slug, &find_user_by_email(email, &1))
  end

  defp find_user_by_email(email, church_or_user) do
    with {:ok, query} <- authorize(User, :find, church_or_user) do
      query
      |> User.by_email(email)
      |> User.preload()
      |> Repo.single()
    end
  end

  defp with_church(slug, func) do
    with {:ok, church} <- Auth.find_church(slug), do: func.(church)
  end

  @doc """
  Authorizes the given resource. If authorized, it returns
  `{:ok, resource}`, otherwise, returns `{:error, reason}`,
  """
  def authorize(User, _action, %Auth.User{} = user), do: Auth.check(User, user)
  def authorize(User, _action, %Auth.Church{} = church), do: Auth.check_church(User, church)

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
