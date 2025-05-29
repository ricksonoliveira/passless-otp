defmodule Passless.Auth.OTP do
  @moduledoc """
  Schema for One-Time Passwords used in the authentication flow.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :code, :string
    field :phone_number, :string
    field :user_id, :integer
    field :expires_at, :utc_datetime
  end

  @doc """
  Changeset for OTP creation and validation.
  """
  def changeset(otp, attrs) do
    otp
    |> cast(attrs, [:code, :phone_number, :user_id, :expires_at])
    |> validate_required([:code, :phone_number, :user_id, :expires_at])
    |> validate_length(:code, is: 6)

    # Add more validations as needed
  end
end
