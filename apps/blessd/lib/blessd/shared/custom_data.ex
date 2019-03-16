defmodule Blessd.Shared.CustomData do
  @moduledoc false

  import Ecto.Changeset

  alias Blessd.Shared.Fields

  @doc false
  def changeset(resource, custom_data, attrs, church_id) do
    fields = Fields.all(resource, church_id)

    types =
      fields
      |> Stream.map(&{Fields.name(&1), String.to_existing_atom(&1.type)})
      |> Enum.into(%{})

    field_ids = Enum.map(fields, & &1.id)

    custom_data =
      custom_data
      |> Stream.filter(fn
        {key, _} when is_atom(key) -> types[key] != nil
        {"field" <> id, _} -> String.to_integer(id) in field_ids
      end)
      |> Stream.map(fn
        {key, value} when is_binary(key) -> {String.to_existing_atom(key), value}
        {key, value} when is_atom(key) -> {key, value}
      end)
      |> Enum.into(%{})

    {custom_data, types}
    |> cast(attrs, Enum.map(fields, &Fields.name/1))
    |> validate_fields(fields)
  end

  defp validate_fields(changeset, fields) do
    Enum.reduce(fields, changeset, &validate_field/2)
  end

  defp validate_field(field, changeset) do
    validate_field(changeset, Fields.name(field), Map.to_list(field.validations))
  end

  defp validate_field(changeset, _, []), do: changeset

  defp validate_field(changeset, name, [{:required, true} | t]) do
    changeset
    |> validate_required(name)
    |> validate_field(name, t)
  end

  defp validate_field(changeset, field_name, [_ | t]) do
    validate_field(changeset, field_name, t)
  end

  def put_change(%{data: data} = changeset, field, resource, attrs) do
    case changeset(resource, Map.get(data, field), attrs, data.church_id) do
      %Ecto.Changeset{valid?: true} = cs ->
        put_change(changeset, field, apply_changes(cs))

      %Ecto.Changeset{valid?: false} = cs ->
        changeset
        |> add_error(field, "is invalid")
        |> put_change(field, cs)
    end
  end
end
