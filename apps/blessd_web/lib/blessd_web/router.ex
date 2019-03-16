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

  pipeline :language do
    plug BlessdWeb.LanguagePlug
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", BlessdWeb do
    pipe_through [:browser, :language]

    get "/", PageController, :index

    resources "/signup", SignupController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create]
    resources "/church_recovery", ChurchRecoveryController, only: [:new, :create, :edit, :update]
    resources "/password_reset", PasswordResetController, only: [:new, :create]
  end

  scope "/:church_slug", BlessdWeb do
    pipe_through [:browser, :language]

    resources "/confirmation", ConfirmationController, only: [:show]
    resources "/invitation", InvitationController, only: [:edit, :update]
    resources "/password_reset", PasswordResetController, only: [:edit, :update]
  end

  scope "/:church_slug", BlessdWeb do
    pipe_through [:browser, :authenticated, :language]

    get "/", DashboardController, :index

    resources "/confirmation", ConfirmationController, only: [:create]
    resources "/invitation", InvitationController, only: [:new, :create]
    resources "/church", ChurchController, only: [:edit, :update, :delete], singleton: true
    resources "/import", ImportController, only: [:create]
    resources "/people", PersonController, except: [:show]
    resources "/users", UserController, except: [:show, :new, :create]
    resources "/session", SessionController, only: [:delete], singleton: true

    resources "/meetings", MeetingController do
      resources "/occurrences", MeetingOccurrenceController,
        only: [:new, :create],
        as: :occurrence
    end

    resources "/meeting_occurrences", MeetingOccurrenceController,
      only: [:show, :edit, :update, :delete] do
      resources "/attendance", AttendanceController, only: [:index, :create]
      resources "/person", PersonController, only: [:create]
    end

    scope "/:resource" do
      resources "/custom_fields", CustomFieldController, except: [:show]
    end
  end
end
