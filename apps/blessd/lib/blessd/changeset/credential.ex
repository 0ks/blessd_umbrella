defmodule Blessd.Changeset.Credential do
  import Ecto.Changeset

  alias Comeonin.Bcrypt

  @valid_sources ~w(password)

  @doc false
  def cast(credential, attrs) do
    cast(credential, attrs, [:source, :token])
  end

  @doc false
  def validate_basic(changeset) do
    changeset
    |> validate_required([:source, :token])
    |> validate_inclusion(:source, @valid_sources)
    |> validate_token()
    |> hash_token()
  end

  @doc false
  def validate_all(changeset) do
    changeset
    |> validate_basic()
    |> validate_required([:church_id, :user_id])
  end

  defp validate_token(%Ecto.Changeset{valid?: true} = changeset) do
    case get_field(changeset, :source) do
      "password" -> validate_length(changeset, :token, min: 8)
    end
  end

  defp validate_token(changeset), do: changeset

  defp hash_token(%Ecto.Changeset{valid?: true} = changeset) do
    case get_field(changeset, :source) do
      "password" ->
        token =
          changeset
          |> get_field(:token)
          |> Bcrypt.hashpwsalt()

        put_change(changeset, :token, token)
    end
  end

  defp hash_token(changeset), do: changeset
end
