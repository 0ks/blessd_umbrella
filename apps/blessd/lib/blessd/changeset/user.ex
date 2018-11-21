defmodule Blessd.Changeset.User do
  import Ecto.Changeset

  alias Blessd.Changeset.Email

  @doc false
  def cast(user, attrs) do
    cast(user, attrs, [:name, :email])
  end

  @doc false
  def validate_basic(changeset) do
    changeset
    |> Email.normalize()
    |> validate_required([:name, :email])
    |> Email.validate()
  end

  @doc false
  def validate_all(changeset) do
    changeset
    |> validate_basic()
    |> validate_required(:church_id)
  end

  @doc false
  def put_confirmation(changeset) do
    changeset
    |> put_change(:confirmation_token, generate_token())
    |> put_change(:confirmed_at, nil)
    |> validate_confirmation()
  end

  @doc false
  def put_confirmed_at(changeset) do
    changeset
    |> validate_confirmation()
    |> put_change(:confirmation_token, nil)
    |> put_change(:confirmed_at, utc_now())
    |> validate_required(:confirmed_at)
  end

  @doc false
  def validate_confirmation(changeset) do
    changeset
    |> get_field(:confirmation_token)
    |> expired_token?()
    |> case do
      true -> add_error(changeset, :confirmation_token, "is expired", validation: :expired)
      false -> changeset
    end
    |> validate_required(:confirmation_token)
  end

  @doc false
  def put_invitation(changeset) do
    changeset
    |> put_change(:invitation_token, generate_token())
    |> put_change(:confirmed_at, nil)
    |> validate_invitation()
  end

  @doc false
  def put_invited_at(changeset) do
    changeset
    |> validate_invitation()
    |> put_change(:invitation_token, nil)
    |> put_change(:confirmed_at, utc_now())
    |> validate_required(:confirmed_at)
  end

  @doc false
  def validate_invitation(changeset) do
    changeset
    |> get_field(:invitation_token)
    |> expired_token?()
    |> case do
      true -> add_error(changeset, :invitation_token, "is expired", validation: :expired)
      false -> changeset
    end
    |> validate_required(:invitation_token)
  end

  @doc false
  def expired_token?(token) do
    with {:ok, decoded} <- Base.url_decode64(token),
         [expires_at_str, _] <- String.split(decoded, ":"),
         {expires_at, _} <- Integer.parse(expires_at_str) do
      expires_at < os_now()
    else
      _ -> true
    end
  end

  @doc false
  def generate_token do
    Base.url_encode64("#{os_now() + 12 * 60 * 60}:#{Ecto.UUID.generate()}")
  end

  defp utc_now, do: DateTime.truncate(DateTime.utc_now(), :second)

  defp os_now, do: :os.system_time(:seconds)
end
