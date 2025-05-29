defmodule PasslessWeb.API.V1.AuthControllerTest do
  use PasslessWeb.ConnCase, async: false

  alias Passless.Auth
  alias Passless.Auth.User
  alias Passless.Repo
  alias Passless.Fixtures.UserFixtures

  describe "POST /api/v1/auth/request_otp" do
    test "with valid phone number sends OTP and creates user", %{conn: conn} do
      phone_number = UserFixtures.random_phone_number()

      # Capture IO output during test run
      ExUnit.CaptureIO.capture_io(fn ->
        response =
          conn
          |> json_conn(:post, "/api/v1/auth/request_otp", %{"phone_number" => phone_number})
          |> json_response()

        assert {200, %{"data" => %{"message" => "OTP sent successfully"}}} = response
      end)

      # Verify user was created in the database
      assert %User{phone_number: ^phone_number} = Repo.get_by(User, phone_number: phone_number)
    end

    test "with invalid phone number returns error", %{conn: conn} do
      response =
        conn
        |> json_conn(:post, "/api/v1/auth/request_otp", %{"phone_number" => "invalid"})
        |> json_response()

      assert {422, %{"errors" => %{"detail" => "Invalid phone number format"}}} = response
    end

    test "with missing phone_number returns 422", %{conn: conn} do
      response =
        conn
        |> json_conn(:post, "/api/v1/auth/request_otp", %{})
        |> json_response()

      assert {422, _} = response
    end
  end

  describe "POST /api/v1/auth/verify_otp" do
    setup do
      phone_number = UserFixtures.random_phone_number()

      {:ok, _} =
        %User{}
        |> User.changeset(%{phone_number: phone_number})
        |> Repo.insert()

      # Request OTP to have it in cache
      {:ok, _} = Auth.request_otp(phone_number)

      %{phone_number: phone_number}
    end

    test "with valid OTP returns JWT token and user data", %{
      conn: conn,
      phone_number: phone_number
    } do
      # Get the OTP from the cache (in a real test, you'd mock this)
      cache_key = "otp:#{phone_number}"
      %{code: code} = Passless.Cache.get(cache_key)

      response =
        conn
        |> json_conn(:post, "/api/v1/auth/verify_otp", %{
          "phone_number" => phone_number,
          "code" => code
        })
        |> json_response()

      assert {200, %{"data" => data}} = response
      assert %{"token" => _token, "user" => user_data} = data
      assert %{"phone_number" => ^phone_number} = user_data
      assert is_binary(user_data["id"])
    end

    test "with invalid OTP returns error", %{conn: conn, phone_number: phone_number} do
      response =
        conn
        |> json_conn(:post, "/api/v1/auth/verify_otp", %{
          "phone_number" => phone_number,
          "code" => "000000"
        })
        |> json_response()

      assert {401, %{"errors" => %{"detail" => "Invalid or expired OTP code"}}} = response
    end

    test "with non-existent user returns error", %{conn: conn} do
      response =
        conn
        |> json_conn(:post, "/api/v1/auth/verify_otp", %{
          "phone_number" => UserFixtures.random_phone_number(),
          "code" => "123456"
        })
        |> json_response()

      assert {404, %{"errors" => %{"detail" => "User not found"}}} = response
    end

    test "with missing otp returns 422", %{conn: conn} do
      response =
        conn
        |> json_conn(:post, "/api/v1/auth/verify_otp", %{})
        |> json_response()

      assert {422, _} = response
    end
  end
end
