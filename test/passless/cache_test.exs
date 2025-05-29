defmodule Passless.CacheTest do
  # Set to false to avoid race conditions with the Cache
  use Passless.DataCase, async: false

  test "put and get a value" do
    key = "test_key"
    value = %{test: "value"}

    assert :ok = Passless.Cache.put(key, value, ttl: 5_000)
    assert ^value = Passless.Cache.get(key)
  end

  test "get returns nil for non-existent key" do
    assert nil == Passless.Cache.get("non_existent")
  end

  test "delete removes a value" do
    key = "test_key"
    value = %{test: "value"}

    :ok = Passless.Cache.put(key, value, ttl: 5_000)
    assert ^value = Passless.Cache.get(key)

    :ok = Passless.Cache.delete(key)
    assert nil == Passless.Cache.get(key)
  end

  test "value expires after ttl" do
    key = "expiring_key"
    value = %{test: "value"}

    # Use a short but non-zero TTL for testing
    :ok = Passless.Cache.put(key, value, ttl: 100)
    assert ^value = Passless.Cache.get(key)

    # Wait for the TTL to expire (slightly longer to ensure it expires)
    Process.sleep(200)
    assert nil == Passless.Cache.get(key)
  end
end
