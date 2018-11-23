defmodule Blessd.Auth.Churches.Church do
  use Ecto.Schema

  schema "churches" do
    field(:name, :string)
    field(:slug, :string)
  end
end
