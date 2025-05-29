defmodule Passless.CacheCase do
  @moduledoc """
  Test case for the Cache module.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Passless.Cache
    end
  end
end
