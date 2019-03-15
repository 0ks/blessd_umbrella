defmodule Blessd.Date do
  @moduledoc """
  Useful functions to work with dates
  """

  alias Blessd.Shared.Churches.Church
  alias Blessd.Shared.Users.User

  @doc """
  Returns the current date according to the given church timezone
  """
  def today(%User{church: church}), do: today(church)
  def today(%Church{timezone: timezone}), do: today(timezone)
  def today(timezone), do: timezone |> Timex.now() |> Timex.to_date()
end
