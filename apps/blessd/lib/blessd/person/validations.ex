defmodule Blessd.Person.Validations do
  @moduledoc """
  Validations for people
  """

  import Ecto.Changeset

  @doc false
  def basic(changeset) do
    changeset
    |> normalize_email()
    |> validate_required([:name, :is_member])
    |> validate_format(:email, ~r/@/)
  end

  defp normalize_email(%Ecto.Changeset{changes: %{email: email}} = changeset) when email != nil do
    new_email =
      email
      |> String.downcase()
      |> String.trim()

    put_change(changeset, :email, new_email)
  end

  defp normalize_email(changeset), do: changeset
end
