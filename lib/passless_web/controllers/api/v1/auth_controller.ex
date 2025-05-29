defmodule PasslessWeb.API.V1.AuthController do
  use PasslessWeb, :controller
  use PhoenixSwagger

  action_fallback PasslessWeb.API.FallbackController

  alias Passless.Auth
  alias PasslessWeb.Auth.Guardian

  def swagger_definitions do
    %{
      OTP:
        swagger_schema do
          title("OTP")
          description("OTP for phone number verification")

          properties do
            phone_number(:string, "Phone number")
            code(:string, "OTP code")
            user(:object, "User")
            expires_at(:string, "OTP expiration time")
          end

          example(%{
            phone_number: "1234567890",
            code: "123456",
            user: %{
              id: "1",
              phone_number: "1234567890"
            },
            expires_at: "2025-05-29T18:41:59Z"
          })
        end
    }
  end

  swagger_path :request_otp do
    get("/auth/request_otp")

    parameters do
      phone_number(:query, :string, "Phone number")
    end

    response(200, "OTP sent successfully")
    response(400, "Missing phone number")
  end

  @doc """
  Request an OTP for phone number verification.

  This endpoint sends a one-time password (OTP) to the provided phone number
  for verification purposes. The OTP will be valid for a limited time.
  """
  def request_otp(conn, %{"phone_number" => phone_number})
      when is_binary(phone_number) and phone_number != "" do
    with {:ok, otp} <- Auth.request_otp(phone_number) do
      IO.puts("USE THIS OTP CODE FOR VERIFICATION: #{otp.code}")

      json(conn, %{
        data: %{
          message: "OTP sent successfully"
        }
      })
    end
  end

  def request_otp(_conn, _params) do
    {:error, :missing_phone_number}
  end

  swagger_path :verify_otp do
    post("/auth/verify_otp")

    parameters do
      phone_number(:query, :string, "Phone number")
      code(:query, :string, "OTP code")
    end

    response(200, "OTP verified successfully")
    response(400, "Missing phone number or OTP code")
    response(401, "Invalid OTP code")
  end

  @doc """
  Verify the OTP and authenticate the user.

  This endpoint verifies the one-time password (OTP) sent to the user's phone number
  and returns a JWT token for authenticated requests if verification is successful.
  """
  def verify_otp(conn, %{"phone_number" => phone_number, "code" => code})
      when is_binary(phone_number) and phone_number != "" and is_binary(code) and code != "" do
    with {:ok, %{user: user}} <- Auth.verify_otp(phone_number, code),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:ok)
      |> json(%{
        data: %{
          token: token,
          user: %{
            id: to_string(user.id),
            phone_number: user.phone_number
          }
        }
      })
    end
  end

  def verify_otp(_conn, _params) do
    {:error, :missing_otp}
  end
end
