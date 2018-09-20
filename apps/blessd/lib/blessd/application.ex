defmodule Blessd.Application do
  @moduledoc """
  The Blessd Application Service.

  The blessd system business domain lives in this application.

  Exposes API to clients such as the `BlessdWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [
        supervisor(Blessd.Repo, [])
      ],
      strategy: :one_for_one,
      name: Blessd.Supervisor
    )
  end
end
