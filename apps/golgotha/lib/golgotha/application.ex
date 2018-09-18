defmodule Golgotha.Application do
  @moduledoc """
  The Golgotha Application Service.

  The golgotha system business domain lives in this application.

  Exposes API to clients such as the `GolgothaWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [
        supervisor(Golgotha.Repo, [])
      ],
      strategy: :one_for_one,
      name: Golgotha.Supervisor
    )
  end
end
