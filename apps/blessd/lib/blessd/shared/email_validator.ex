defmodule Blessd.Shared.EmailValidator do
  import Ecto.Changeset

  def normalize_email(changeset, field) do
    case get_field(changeset, field) do
      nil ->
        changeset

      email ->
        new_email =
          email
          |> String.downcase()
          |> String.trim()

        put_change(changeset, field, new_email)
    end
  end

  def validate_email(changeset, field), do: validate_format(changeset, field, ~r/@/)
end
