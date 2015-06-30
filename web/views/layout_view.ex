defmodule Skipper.LayoutView do
  use Skipper.Web, :view

  def current_user(conn) do
    conn.assigns[:current_user]
  end
end
