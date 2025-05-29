defmodule PasslessWeb.Auth.Guardian do
  @moduledoc """
  Guardian implementation for JWT authentication.
  """
  use Guardian, otp_app: :passless
  alias Passless.Auth.User
  alias Passless.Repo

  def subject_for_token(%User{} = user, _claims) do
    {:ok, "User:#{user.id}"}
  end

  def subject_for_token(_, _) do
    {:error, :invalid_resource}
  end

  def resource_from_claims(%{"sub" => "User:" <> user_id}) do
    case Repo.get(User, String.to_integer(user_id)) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end
end
