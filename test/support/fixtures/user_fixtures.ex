defmodule Passless.Fixtures.UserFixtures do
  @moduledoc """
  This module defines test helpers for creating
  user related test data.
  """

  @doc """
  Generate a random phone number in E.164 format.
  Example: "+14155552671"
  """
  def random_phone_number do
    # Generate a random country code (1-99)
    country_code = :rand.uniform(98) + 1
    # Generate a random national number (10-15 digits)
    national_number =
      (:rand.uniform(899_999_999_999_999) + 100_000_000_000)
      |> to_string()
      # Ensure 10 digits
      |> String.slice(0..9)

    "+#{country_code}#{national_number}"
  end

  @doc """
  Generate a random 6-digit OTP code as a string.
  """
  def random_otp do
    (:rand.uniform(899_999) + 100_000)
    |> to_string()
  end
end
