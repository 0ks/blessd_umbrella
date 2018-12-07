defmodule Blessd.Shared.Fields.Field do
  @moduledoc false

  use Ecto.Schema

  alias Blessd.Shared.Churches.Church
  alias Blessd.Shared.Fields.Field.Validations

  schema "custom_fields" do
    belongs_to(:church, Church)

    field :resource, :string
    field :name, :string
    field :type, :string
    field :position, :integer

    embeds_one :validations, Validations
  end
end

defmodule Blessd.Shared.Fields.Field.Validations do
  @moduledoc false

  use Ecto.Schema

  embedded_schema do
    field :required, :boolean
  end
end
