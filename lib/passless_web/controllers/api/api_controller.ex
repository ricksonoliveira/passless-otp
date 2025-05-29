defmodule PasslessWeb.API.APIController do
  @moduledoc """
  Base controller for all API endpoints.
  Provides common functionality and error handling.
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use Phoenix.Controller, Keyword.take(opts, [:namespace, :put_default_views])

      import Plug.Conn
      import Phoenix.Controller

      def render_error(conn, status, message) when is_binary(message) do
        conn
        |> put_status(status)
        |> put_view(PasslessWeb.API.ErrorView)
        |> render("error.json", reason: message)
      end

      def render_validation_errors(conn, changeset) do
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(PasslessWeb.API.ErrorView)
        |> render("error.json", reason: changeset)
      end

      defoverridable render_error: 3, render_validation_errors: 2
    end
  end
end
