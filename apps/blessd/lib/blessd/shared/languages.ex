defmodule Blessd.Shared.Languages do
  @moduledoc """
  Secondary context for languages
  """

  @doc false
  def list, do: ~w(en pt_br)

  @doc false
  def default, do: "en"
end
