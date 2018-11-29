defmodule Blessd.Custom.Fields.Field do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Blessd.Custom.Fields.Field
  alias Blessd.Shared.Churches.Church
  alias Blessd.Shared.Fields.Field.Validations

  schema "custom_fields" do
    belongs_to(:church, Church)

    field :resource_type, :string
    field :name, :string
    field :type, :string
    field :position, :integer

    embeds_one :validations, Validations

    timestamps()
  end

  @doc false
  def new_changeset(%Field{} = field, attrs) do
    field
    |> cast_all(attrs)
    |> validate_all()
  end

  @doc false
  def edit_changeset(%Field{} = field, attrs) do
    field
    |> cast_basic(attrs)
    |> validate_all()
  end

  @doc false
  def reorder_changeset(%Field{} = field, attrs) do
    field
    |> cast(attrs, [:position])
    |> validate_required(:position)
  end

  defp cast_basic(field, attrs) do
    field
    |> cast(attrs, [:name, :type])
    |> cast_embed(:validations, required: true)
  end

  defp cast_all(field, attrs) do
    field
    |> cast_basic(attrs)
    |> cast(attrs, [:resource_type])
  end

  defp validate_all(changeset) do
    changeset
    |> validate_required([:resource_type, :name, :type])
    |> validate_inclusion(:resource_type, valid_resource_types())
    |> validate_inclusion(:type, valid_types())
  end

  @doc false
  def valid_resource_types, do: ~w(person)

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
