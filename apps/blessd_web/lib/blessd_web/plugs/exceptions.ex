errors = [
  {Blessd.NotAuthorizedError, 403}
]

for {exception, status_code} <- errors do
  defimpl Plug.Exception, for: exception do
    def status(_), do: unquote(status_code)
  end
end
