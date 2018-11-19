defmodule Blessd.Confirmation.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Auth.Church
  alias Blessd.Confirmation.User

  schema "users" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:email, :string)
    field(:confirmation_token, :string)
    field(:confirmed_at, :utc_datetime)

    timestamps()
  end

  @doc false
  def token_changeset(%User{} = user) do
    user
    |> change(%{confirmation_token: generate_token(), confirmed_at: nil})
    |> validate_confirmation()
  end

  @doc false
  def confirm_changeset(%User{} = user) do
    user
    |> change(%{confirmed_at: utc_now()})
    |> validate_confirmation()
    |> put_change(:confirmation_token, nil)
    |> validate_required(:confirmed_at)
  end

  defp validate_confirmation(changeset) do
    with {:ok, decoded} <- changeset |> get_field(:confirmation_token) |> Base.url_decode64(),
         [expires_at_str, _] <- String.split(decoded, ":"),
         {expires_at, _} <- Integer.parse(expires_at_str) do
      if expires_at < os_now() do
        add_error(changeset, :confirmation_token, "is expired", [validation: :expired])
      else
        changeset
      end
    else
      _ -> add_error(changeset, :confirmation_token, "is invalid", [validation: :format])
    end
    |> validate_required(:confirmation_token)
  end

  defp utc_now, do: DateTime.truncate(DateTime.utc_now(), :second)

  defp os_now, do: :os.system_time(:seconds)

  defp generate_token do
    Base.url_encode64("#{os_now() + 12 * 60 * 60}:#{:crypto.strong_rand_bytes(30)}")
  end
end
