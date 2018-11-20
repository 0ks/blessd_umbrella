defmodule Blessd.Invitation.User do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Blessd.Auth.Church
  alias Blessd.Invitation.User

  schema "users" do
    belongs_to(:church, Church)

    field(:name, :string)
    field(:email, :string)
    field(:invitation_token, :string)
    field(:accepted_at, :utc_datetime)

    timestamps()
  end

  @doc false
  def token_changeset(%User{} = user) do
    user
    |> change(%{invitation_token: generate_token(), confirmed_at: nil})
    |> validate_invitation()
  end

  @doc false
  def accept_changeset(%User{} = user) do
    user
    |> change(%{confirmed_at: utc_now()})
    |> validate_invitation()
    |> put_change(:invitation_token, nil)
    |> validate_required(:confirmed_at)
  end

  defp validate_invitation(changeset) do
    with {:ok, decoded} <- changeset |> get_field(:invitation_token) |> Base.url_decode64(),
         [expires_at_str, _] <- String.split(decoded, ":"),
         {expires_at, _} <- Integer.parse(expires_at_str) do
      if expires_at < os_now() do
        add_error(changeset, :invitation_token, "is expired", validation: :expired)
      else
        changeset
      end
    else
      _ -> add_error(changeset, :invitation_token, "is invalid", validation: :format)
    end
    |> validate_required(:invitation_token)
  end

  defp utc_now, do: DateTime.truncate(DateTime.utc_now(), :second)

  defp os_now, do: :os.system_time(:seconds)

  defp generate_token do
    Base.url_encode64("#{os_now() + 12 * 60 * 60}:#{Ecto.UUID.generate()}")
  end

  @doc false
  def by_church(query, %Church{id: church_id}), do: by_church(query, church_id)
  def by_church(query, church_id), do: where(query, [u], u.church_id == ^church_id)

  @doc false
  def by_token(query, token), do: where(query, [u], u.invitation_token == ^token)

  @doc false
  def preload(query) do
    preload(query, [u], :church)
  end
end
