defmodule PasslessWeb.Router do
  use PasslessWeb, :router

  # Define pipelines
  pipeline :api do
    plug :accepts, ["json"]
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Passless API"
      }
    }
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PasslessWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # Swagger pipeline
  pipeline :swagger do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
  end

  # API scope
  scope "/api/v1", PasslessWeb.API.V1 do
    pipe_through :api

    post "/auth/request_otp", AuthController, :request_otp
    post "/auth/verify_otp", AuthController, :verify_otp
  end

  # Swagger API documentation
  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :passless, swagger_file: "swagger.json"
  end

  # Redirect root to Swagger UI
  get "/", PasslessWeb.RedirectController, :index, private: %{redirect_to: "/api/swagger"}

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:passless, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PasslessWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
