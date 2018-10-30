defmodule Blessd.Auth.Church do
  use Ecto.Schema

  schema "churches" do
    field(:identifier, :string)
  end
end
