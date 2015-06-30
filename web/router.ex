defmodule Skipper.Router do
  use Skipper.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Skipper do
    pipe_through :browser # Use the default browser stack

    get "register_form", AuthController, :register_form
    post "register", AuthController, :register
    get "login_form", AuthController, :login_form
    post "login", AuthController, :login
    get "sign_out", AuthController, :sign_out

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Skipper do
  #   pipe_through :api
  # end
end
