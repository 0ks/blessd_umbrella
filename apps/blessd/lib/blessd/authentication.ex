defmodule Blessd.Authentication do
  @moduledoc """
  The Authentication context.
  """

  import Ecto.Changeset, only: [apply_action: 2]

  alias Blessd.Authentication.Session

  @doc """
  Authenticates the user on a church by email and password.
  """
  def authenticate(params) do
    %Session{church: nil, user: nil}
    |> Session.changeset(params)
    |> apply_action(:insert)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session creation.
  """
  def new_session, do: Session.changeset(%Session{}, %{})
end
