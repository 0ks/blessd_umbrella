defmodule Blessd.Changeset.Email do
  import Ecto.Changeset

  def normalize(%Ecto.Changeset{changes: %{email: email}} = changeset) when email != nil do
    new_email =
      email
      |> String.downcase()
      |> String.trim()

    put_change(changeset, :email, new_email)
  end

  def normalize(changeset), do: changeset

  def validate(changeset), do: validate_format(changeset, :email, ~r/@/)
end
