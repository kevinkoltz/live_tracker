defmodule LiveTracker.Sessions.SessionStore do
  @moduledoc """
  Server process for managing cached state of user sessions.

  If the server goes down, session state will not be restored. This is ok
  because these sessions are intended to be temporary, for now.
  """
  use GenServer

  alias LiveTracker.Sessions.Session

  @name __MODULE__

  def start_link(opts \\ []) do
    args = []
    GenServer.start_link(@name, args, opts)
  end

  @spec get(non_neg_integer()) :: {:error, :not_found} | {:ok, Session.t()}
  def get(id) do
    case GenServer.call(@name, {:get, id}) do
      [] -> {:error, :not_found}
      [{_, session}] -> {:ok, session}
    end
  end

  @spec insert(Session.t()) :: {:ok, Session.t()}
  def insert(%Session{} = session) do
    {:ok, GenServer.call(@name, {:insert, session})}
  end

  # GenServer callbacks

  def handle_call({:get, id}, _from, state) do
    result = :ets.lookup(:sessions, id)
    {:reply, result, state}
  end

  def handle_call({:insert, session}, _from, state) do
    true = :ets.insert(:sessions, {session.id, session})
    {:reply, session, state}
  end

  def init(_args) do
    :ets.new(:sessions, [:named_table, :set, :private])

    {:ok, %{}}
  end
end
