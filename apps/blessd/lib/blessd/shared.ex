defmodule Blessd.Shared do
  @moduledoc """
  Inside this context we have a list of secondary context
  shared by all the other contexts. Its only purpose is
  to hold the functions that can be reused accross
  contexts.

  Warning: just put something inside this context if you
  have a reason for it, please do not put it here because
  "you're for sure going to reuse it in the future", wait
  for the reuse opportunity to come, and then move the
  functions here.
  """
end

