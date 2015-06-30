defmodule Skipper.PageController do
  use Skipper.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
