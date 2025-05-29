defmodule PasslessWeb.API.ErrorView do
  @moduledoc """
  Handles rendering of error responses in the API.
  """

  def render("error.json", %{reason: %Ecto.Changeset{} = changeset}) do
    %{
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  def render("error.json", %{reason: message}) when is_binary(message) do
    %{
      errors: %{detail: message}
    }
  end

  def render("error.json", %{reason: %{message: message}}) do
    %{
      errors: %{detail: message}
    }
  end

  def render("error.json", %{reason: reason}) do
    %{
      errors: %{detail: "An error occurred: #{inspect(reason)}"}
    }
  end

  def render("404.json", _assigns) do
    %{errors: %{detail: "Not Found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal Server Error"}}
  end

  def render(template, _assigns) do
    %{errors: %{detail: "An unexpected error occurred: #{template}"}}
  end

  defp translate_error({msg, opts}) do
    # You can use gettext to translate your errors
    if count = opts[:count] do
      Gettext.dngettext(PasslessWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(PasslessWeb.Gettext, "errors", msg, opts)
    end
  end
end
