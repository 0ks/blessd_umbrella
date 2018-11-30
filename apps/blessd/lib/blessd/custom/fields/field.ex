defmodule Blessd.Custom.Fields.Field do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Custom.Fields.Field
  alias Blessd.Shared.Churches.Church
  alias Blessd.Shared.Fields.Field.Validations

  schema "custom_fields" do
    belongs_to(:church, Church)

    field :resource, :string
    field :name, :string
    field :type, :string
    field :position, :integer

    embeds_one :validations, Validations

    timestamps()
  end

  @doc false
  def changeset(%Field{} = field, attrs) do
    field
    |> cast_all(attrs)
    |> validate_all()
  end

  @doc false
  def reorder_changeset(%Field{} = field, attrs) do
    field
    |> cast(attrs, [:position])
    |> validate_required(:position)
  end

  defp cast_all(field, attrs) do
    field
    |> cast(attrs, [:name, :type])
    |> cast_embed(:validations, required: true)
  end

  defp validate_all(changeset) do
    changeset
    |> validate_required([:resource, :name, :type])
    |> validate_inclusion(:resource, valid_resources())
    |> validate_inclusion(:type, valid_types())
  end

  @doc false
  def valid_resources, do: ~w(person)

  @doc false
  def valid_types, do: ~w(string date)
end

defmodule Blessd.Shared.Fields.Field.Validations do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Shared.Fields.Field.Validations

  embedded_schema do
    field :required, :boolean
  end

  @doc false
  def changeset(%Validations{} = field, attrs) do
    field
    |> cast(attrs, [:required])
    |> validate_required(:required)
  end
end
