defmodule GolgothaWeb.Router do
  use GolgothaWeb, :router

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

  scope "/", GolgothaWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    resources("/people", PersonController, except: [:show])
  end

  # Other scopes may use custom stacks.
  # scope "/api", GolgothaWeb do
  #   pipe_through :api
  # end
end
