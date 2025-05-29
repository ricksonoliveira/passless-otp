defmodule PasslessWeb.RedirectController do
  @moduledoc """
  Handles redirects for the application.
  """
  use PasslessWeb, :controller

  @doc """
  Redirects to the given path.
  """
  def index(conn, _params) do
    to = conn.private[:redirect_to] || "/"
    redirect(conn, to: to)
  end
end
