defmodule Passless.Auth do
  @moduledoc """
  The Auth context for handling authentication related functionality.
  """
  import Ecto.Query, warn: false
  alias Passless.Auth.OTP
  alias Passless.Auth.User
  alias Passless.Repo
  alias Passless.Cache

  # 5 minutes
  @otp_expiry_seconds 300

  @doc """
  Requests an OTP for the given phone number.
  Creates a new user if one doesn't exist with the phone number.
  """
  def request_otp(phone_number) when is_binary(phone_number) do
    with {:ok, _} <- validate_phone_number(phone_number),
         {:ok, user} <- find_or_create_user(phone_number),
         {:ok, otp} <- generate_and_store_otp(user) do
      {:ok, otp}
    end
  end

  @doc """
  Verifies the provided OTP code for the given phone number.
  Returns the user if the OTP is valid.
  """
  def verify_otp(phone_number, code) when is_binary(phone_number) and is_binary(code) do
    with {:ok, user} <- get_user_by_phone(phone_number),
         :ok <- verify_otp_code(user, code) do
      {:ok, %{user: user}}
    end
  end

  defp validate_phone_number(phone_number) do
    # Basic phone number validation
    if String.match?(phone_number, ~r/^\+?[1-9]\d{1,14}$/) do
      {:ok, phone_number}
    else
      {:error, "Invalid phone number format"}
    end
  end

  defp find_or_create_user(phone_number) do
    case Repo.get_by(User, phone_number: phone_number) do
      nil ->
        %User{}
        |> User.changeset(%{phone_number: phone_number})
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end

  defp generate_and_store_otp(user) do
    code = (:rand.uniform(899_999) + 100_000) |> to_string()
    expires_at = DateTime.utc_now() |> DateTime.add(@otp_expiry_seconds, :second)

    otp = %OTP{
      code: code,
      phone_number: user.phone_number,
      user_id: user.id,
      expires_at: expires_at
    }

    # Store in cache with expiry
    cache_key = "otp:#{user.phone_number}"
    :ok = Cache.put(cache_key, otp, ttl: @otp_expiry_seconds * 1000)

    {:ok, otp}
  end

  defp get_user_by_phone(phone_number) do
    case Repo.get_by(User, phone_number: phone_number) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  defp verify_otp_code(user, code) do
    cache_key = "otp:#{user.phone_number}"

    case Cache.get(cache_key) do
      nil ->
        {:error, :invalid_otp}

      %OTP{code: ^code, expires_at: expires_at} = _otp ->
        if DateTime.compare(DateTime.utc_now(), expires_at) == :lt do
          # Clean up the used OTP
          Cache.delete(cache_key)
          :ok
        else
          {:error, :otp_expired}
        end

      _ ->
        {:error, :invalid_otp}
    end
  end
end
