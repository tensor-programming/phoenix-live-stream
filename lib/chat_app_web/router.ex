defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ChatAppWeb.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatAppWeb do
    pipe_through :browser

    get "/", RoomController, :index
    resources("/rooms", RoomController, except: [:index])
    resources("/sessions", SessionController, only: [:new, :create])
    resources "/registration", RegistrationController, only: [:new, :create]
    delete "/sign_out", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChatAppWeb do
  #   pipe_through :api
  # end
end
