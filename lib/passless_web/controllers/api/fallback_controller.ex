defmodule PasslessWeb.API.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  """
  use PasslessWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(PasslessWeb.API.ErrorView)
    |> render("error.json", reason: changeset)
  end

  # This clause handles validation errors from our code.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(PasslessWeb.API.ErrorView)
    |> render("404.json")
  end

  # Handle user not found
  def call(conn, {:error, :user_not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(PasslessWeb.API.ErrorView)
    |> render("error.json", reason: "User not found")
  end

  # Handle invalid OTP
  def call(conn, {:error, :invalid_otp}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(PasslessWeb.API.ErrorView)
    |> render("error.json", reason: "Invalid or expired OTP code")
  end

  # Handle invalid resource
  def call(conn, {:error, :invalid_resource}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(PasslessWeb.API.ErrorView)
    |> render("error.json", reason: "Invalid resource")
  end

  # Handle missing phone number
  def call(conn, {:error, :missing_phone_number}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(PasslessWeb.API.ErrorView)
    |> render("error.json", reason: "Phone number is required")
  end

  def call(conn, {:error, :missing_otp}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(PasslessWeb.API.ErrorView)
    |> render("error.json", reason: "OTP is required")
  end

  # Fallback for any other error
  def call(conn, {:error, reason}) when is_binary(reason) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(PasslessWeb.API.ErrorView)
    |> render("error.json", reason: reason)
  end
end
