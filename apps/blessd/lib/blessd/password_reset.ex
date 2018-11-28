defmodule Blessd.PasswordReset do
  @moduledoc """
  The PasswordReset context.
  """

  import Ecto.Changeset
  import Blessd.Shared.Users.User, only: [validate_password_reset: 1]

  alias Blessd.Shared
  alias Blessd.PasswordReset.Credential
  alias Blessd.PasswordReset.User
  alias Blessd.PasswordReset.TokenData
  alias Blessd.Repo

  def generate_token(user_id, slug) do
    with {:ok, user} <- find_user(user_id, slug) do
      user
      |> User.token_changeset()
      |> Repo.update()
    end
  end

  def generate_token(%{} = attrs) do
    with {:ok, token_data} <- validate_token_data(attrs),
         {:ok, user} <- find_user_by_email(token_data) do
      user
      |> User.token_changeset()
      |> Repo.update()
      |> case do
        {:ok, user} -> {:ok, user}
        {:error, %Ecto.Changeset{}} -> {:error, :token_generation_failed}
      end
    end
  end

  defp validate_token_data(attrs) do
    %TokenData{church_slug: nil, email: nil}
    |> TokenData.changeset(attrs)
    |> apply_action(:insert)
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

  defp find_user(id, slug) when is_binary(slug) do
    with_church(slug, &find_user(id, &1))
  end

  defp find_user(id, church_or_user) do
    with {:ok, query} <- authorize(User, :find, church_or_user) do
      query
      |> User.preload()
      |> Repo.find(id)
    end
  end

  defp find_user_by_token(token, slug) when is_binary(slug) do
    with_church(slug, &find_user_by_token(token, &1))
  end

  defp find_user_by_token(token, church_or_user) do
    with {:ok, query} <- authorize(User, :find, church_or_user) do
      query
      |> User.preload()
      |> Repo.find_by(password_reset_token: token)
    end
  end

  defp find_user_by_email(%TokenData{email: email, church_slug: slug}) do
    find_user_by_email(email, slug)
  end

  defp find_user_by_email(email, slug) when is_binary(slug) do
    with_church(slug, &find_user_by_email(email, &1))
  end

  defp find_user_by_email(email, church_or_user) do
    with {:ok, query} <- authorize(User, :find, church_or_user) do
      query
      |> User.preload()
      |> Repo.find_by(email: email)
    end
  end

  defp with_church(slug, func) do
    with {:ok, church} <- Shared.find_church(slug), do: func.(church)
  end

  @doc """
  Sharedorizes the given resource. If authorized, it returns
  `{:ok, resource}`, otherwise, returns `{:error, reason}`,
  """
  def authorize(User, _action, church_or_user), do: Shared.authorize(User, church_or_user)

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
