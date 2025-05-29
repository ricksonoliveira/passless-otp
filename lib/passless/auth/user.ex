defmodule Passless.Auth.User do
  @moduledoc """
  User schema and authentication-related functionality.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "users" do
    field :phone_number, :string
    field :inserted_at, :utc_datetime
    field :updated_at, :utc_datetime
  end

  @doc """
  Changeset for user creation and updates.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:phone_number])
    |> validate_required([:phone_number])
    |> unique_constraint(:phone_number, name: :users_phone_number_index)
    |> validate_format(:phone_number, ~r/^\+?[1-9]\d{1,14}$/,
      message: "must be a valid phone number with country code"
    )
  end
end
