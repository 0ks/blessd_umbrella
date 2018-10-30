defmodule Blessd.Signup.Credential do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Auth.Church
  alias Blessd.Signup.Credential
  alias Blessd.Signup.User
  alias Comeonin.Bcrypt

  schema "credentials" do
    belongs_to(:church, Church)
    belongs_to(:user, User)

    field(:source, :string)
    field(:token, :string)

    timestamps()
  end

  @valid_sources ~w(password)

  @doc false
  def changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs)
    |> validate_all()
  end

  @doc false
  def registration_changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs)
    |> validate_basic()
  end

  defp cast(%Credential{} = credential, attrs) do
    cast(credential, attrs, [:source, :token])
  end

  defp validate_basic(changeset) do
    changeset
    |> validate_required([:source, :token])
    |> validate_inclusion(:source, @valid_sources)
    |> validate_token()
    |> hash_token()
  end

  defp validate_all(changeset) do
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
