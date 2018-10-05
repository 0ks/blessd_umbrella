defmodule BlessdWeb.Router do
  use BlessdWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :load_church do
    plug(BlessdWeb.ChurchPlug)
  end

  scope "/", BlessdWeb do
    pipe_through(:browser)

    get("/", PageController, :index)

    resources("/churches", ChurchController, only: [:new, :create])
  end

  scope "/:church_identifier", BlessdWeb do
    pipe_through([:browser, :load_church])

    resources("/churches", ChurchController, only: [:edit, :update, :delete], singleton: true)

    resources("/import", ImportController, only: [:create])
    resources("/people", PersonController, except: [:show])

    resources "/services", ServiceController, except: [:show] do
      resources("/attendance", AttendanceController, only: [:index])
    end
  end
end
