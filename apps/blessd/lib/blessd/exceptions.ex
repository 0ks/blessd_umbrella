defmodule Blessd.NotAuthorizedError do
  defexception [:message]

  alias Blessd.NotAuthorizedError

  @impl true
  def exception(_) do
    %NotAuthorizedError{message: "The current user is not authorized to perform this action."}
  end
end
