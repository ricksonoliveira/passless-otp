defmodule PasslessWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use PasslessWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """
  alias Ecto.Adapters.SQL.Sandbox

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint PasslessWeb.Endpoint

      use PasslessWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import PasslessWeb.ConnCase
      import ExUnit.CaptureLog

      alias PasslessWeb.Router.Helpers, as: Routes

      @endpoint PasslessWeb.Endpoint
    end
  end

  setup tags do
    pid = Sandbox.start_owner!(Passless.Repo, shared: not tags[:async])
    on_exit(fn -> Sandbox.stop_owner(pid) end)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Helper function for making JSON API requests.
  """
  def json_conn(conn, method, path, params \\ nil) do
    conn
    |> Plug.Conn.put_req_header("accept", "application/json")
    |> Plug.Conn.put_req_header("content-type", "application/json")
    |> json_request(method, path, params)
  end

  defp json_request(conn, method, path, nil) do
    conn
    |> Phoenix.ConnTest.dispatch(PasslessWeb.Endpoint, method, path)
  end

  defp json_request(conn, method, path, params) do
    conn
    |> Phoenix.ConnTest.dispatch(
      PasslessWeb.Endpoint,
      method,
      path,
      Jason.encode!(params)
    )
  end

  @doc """
  Helper function for parsing JSON responses.
  """
  def json_response(conn, _status \\ 200) do
    {:ok, body} = conn.resp_body |> Jason.decode()
    {conn.status, body}
  end
end
