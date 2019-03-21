defmodule BlessdWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use BlessdWeb, :controller
      use BlessdWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: BlessdWeb
      import Plug.Conn
      import BlessdWeb.Gettext
      alias BlessdWeb.Router.Helpers, as: Routes

      action_fallback BlessdWeb.FallbackController
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/blessd_web/templates",
        namespace: BlessdWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      import Phoenix.HTML
      import Phoenix.HTML.Link
      import Phoenix.HTML.Tag
      import Phoenix.HTML.Format

      import Phoenix.HTML.Form,
        except: [
          date_input: 2,
          date_input: 3,
          humanize: 1,
          password_input: 2,
          password_input: 3,
          text_input: 2,
          text_input: 3,
          textarea: 2,
          textarea: 3,
          select: 3,
          select: 4
        ]

      import BlessdWeb.ErrorHelpers
      import BlessdWeb.StringHelpers
      import BlessdWeb.FormHelpers
      import BlessdWeb.Gettext

      alias BlessdWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import BlessdWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
