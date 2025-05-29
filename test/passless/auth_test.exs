defmodule Passless.AuthTest do
  # Set to false due to DB sandbox
  use Passless.DataCase, async: false

  alias Passless.Auth
  alias Passless.Auth.User
  alias Passless.Repo

  alias Passless.Fixtures.UserFixtures

  describe "request_otp/1" do
    test "with valid phone number creates a new user and returns OTP" do
      phone_number = UserFixtures.random_phone_number()
      assert {:ok, otp} = Auth.request_otp(phone_number)

      # Verify user was created
      assert %User{phone_number: ^phone_number} = Repo.get_by(User, phone_number: phone_number)

      # Verify OTP is in the expected format
      assert String.length(otp.code) == 6
      assert String.match?(otp.code, ~r/^\d{6}$/)
    end

    test "with existing phone number returns OTP for existing user" do
      phone_number = UserFixtures.random_phone_number()

      {:ok, _} =
        %User{}
        |> User.changeset(%{phone_number: phone_number})
        |> Repo.insert()

      assert {:ok, _otp} = Auth.request_otp(phone_number)
      assert 1 == Repo.aggregate(User, :count, :id)
    end

    test "with invalid phone number returns error" do
      assert {:error, "Invalid phone number format"} = Auth.request_otp("invalid")
    end
  end

  describe "verify_otp/2" do
    setup do
      phone_number = UserFixtures.random_phone_number()

      {:ok, user} =
        %User{}
        |> User.changeset(%{phone_number: phone_number})
        |> Repo.insert()

      %{user: user, phone_number: phone_number}
    end

    test "with valid OTP returns user", %{user: user, phone_number: phone_number} do
      # First request an OTP
      {:ok, otp} = Auth.request_otp(phone_number)

      # Then verify it
      assert {:ok, %{user: returned_user}} = Auth.verify_otp(phone_number, otp.code)

      # Only compare the fields we care about
      assert returned_user.id == user.id
      assert returned_user.phone_number == user.phone_number
    end

    test "with invalid OTP returns error", %{phone_number: phone_number} do
      # Request an OTP but don't use it
      {:ok, _otp} = Auth.request_otp(phone_number)

      # Try with wrong code
      assert {:error, :invalid_otp} = Auth.verify_otp(phone_number, "000000")
    end

    test "with expired OTP returns error", %{phone_number: phone_number} do
      # Manually set an expired OTP in the cache
      cache_key = "otp:#{phone_number}"

      expired_otp = %Auth.OTP{
        code: "123456",
        phone_number: phone_number,
        expires_at: DateTime.utc_now() |> DateTime.add(-60, :second)
      }

      :ok = Passless.Cache.put(cache_key, expired_otp, ttl: 1000)

      assert {:error, :otp_expired} = Auth.verify_otp(phone_number, "123456")
    end

    test "with non-existent user returns error" do
      assert {:error, :user_not_found} =
               Auth.verify_otp(UserFixtures.random_phone_number(), "123456")
    end
  end
end
