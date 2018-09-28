defmodule BlessdWeb.Router do
  use BlessdWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BlessdWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    resources("/people", PersonController, except: [:show])
    resources("/services", ServiceController, except: [:show])
    resources("/attendance", AttendanceController, only: [:index])
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlessdWeb do
  #   pipe_through :api
  # end
end
