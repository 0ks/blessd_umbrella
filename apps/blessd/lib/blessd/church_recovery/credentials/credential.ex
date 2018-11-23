defmodule Blessd.ChurchRecovery.Credentials.Credential do
  use Ecto.Schema

  import Blessd.Shared.Credentials.Credential
  import Ecto.Changeset

  alias Blessd.Auth.Churches.Church
  alias Blessd.ChurchRecovery.Credentials.Credential
  alias Blessd.ChurchRecovery.Users.User

  schema "credentials" do
    belongs_to(:church, Church)
    belongs_to(:user, User)

    field(:source, :string)
    field(:token, :string)

    timestamps()
  end

  @doc false
  def changeset(%Credential{} = credential) do
    credential
    |> cast(%{token: generate_token(2 * 60 * 60), source: "church_recovery"})
    |> validate_token_expired()
  end

  defp validate_token_expired(changeset) do
    changeset
    |> get_field(:token)
    |> expired_token?()
    |> case do
      true -> add_error(changeset, :token, "is expired", validation: :expired)
      false -> changeset
    end
  end

  defp expired_token?(token) do
    with {:ok, decoded} <- Base.url_decode64(token),
         [expires_at_str, _] <- String.split(decoded, ":"),
         {expires_at, _} <- Integer.parse(expires_at_str) do
      expires_at < os_now()
    else
      _ -> true
    end
  end

  defp os_now, do: :os.system_time(:seconds)

  defp generate_token(expires_in) do
    Base.url_encode64("#{os_now() + expires_in}:#{Ecto.UUID.generate()}")
  end
end
