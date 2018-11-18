defmodule BlessdWeb.Router do
  use BlessdWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authenticated do
    plug BlessdWeb.AuthenticationPlug
  end

  scope "/", BlessdWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/signup", SignupController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create]
  end

  scope "/:church_identifier", BlessdWeb do
    pipe_through :browser

    resources "/confirmation/:token", ConfirmationController, only: [:create], singleton: true
  end

  scope "/:church_identifier", BlessdWeb do
    pipe_through [:browser, :authenticated]

    resources "/church", ChurchController, only: [:edit, :update, :delete], singleton: true

    resources "/import", ImportController, only: [:create]
    resources "/people", PersonController, except: [:show]
    resources "/users", UserController, except: [:show, :new, :create]
    resources "/session", SessionController, only: [:delete], singleton: true

    resources "/meetings", MeetingController, except: [:show] do
      resources "/occurrences", MeetingOccurrenceController,
        only: [:new, :create],
        as: :occurrence
    end

    resources "/meeting_occurrences", MeetingOccurrenceController, only: [:edit, :update, :delete] do
      resources "/attendance", AttendanceController, only: [:index]
    end
  end
end
