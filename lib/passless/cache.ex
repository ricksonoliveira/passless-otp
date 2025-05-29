defmodule Passless.Cache do
  @moduledoc """
  Cache wrapper for OTP storage using ETS.
  """
  use GenServer

  @cache_name :otp_cache

  # Client API

  @doc """
  Starts the cache.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Gets a value from the cache.
  """
  def get(key) do
    case :ets.lookup(@cache_name, key) do
      [{^key, value}] -> value
      _ -> nil
    end
  end

  @doc """
  Puts a value in the cache with an optional TTL in milliseconds.
  Returns :ok when the value has been stored.
  """
  def put(key, value, ttl: ttl) do
    GenServer.call(__MODULE__, {:put, key, value, ttl})
  end

  @doc """
  Puts a value in the cache asynchronously with an optional TTL in milliseconds.
  """
  def cast_put(key, value, ttl: ttl) do
    GenServer.cast(__MODULE__, {:put, key, value, ttl})
  end

  @doc """
  Deletes a value from the cache.
  Returns :ok when the value has been deleted.
  """
  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end

  @doc """
  Asynchronously deletes a value from the cache.
  """
  def cast_delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  # Server callbacks

  @impl true
  def init(:ok) do
    # Create the ETS table for the cache
    :ets.new(@cache_name, [:set, :public, :named_table, read_concurrency: true])
    {:ok, %{}}
  end

  @impl true
  def handle_call({:put, key, value, ttl}, _from, state) do
    true = :ets.insert(@cache_name, {key, value})

    # Set up a timer to delete the key after TTL
    if ttl && ttl > 0 do
      Process.send_after(self(), {:expire, key}, ttl)
    end

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:delete, key}, _from, state) do
    :ets.delete(@cache_name, key)
    {:reply, :ok, state}
  end

  @impl true
  def handle_cast({:put, key, value, ttl}, state) do
    true = :ets.insert(@cache_name, {key, value})

    # Set up a timer to delete the key after TTL
    if ttl && ttl > 0 do
      Process.send_after(self(), {:expire, key}, ttl)
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    :ets.delete(@cache_name, key)
    {:noreply, state}
  end

  @impl true
  def handle_info({:expire, key}, state) do
    :ets.delete(@cache_name, key)
    {:noreply, state}
  end
end
