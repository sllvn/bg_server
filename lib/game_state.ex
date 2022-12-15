defmodule GameState do
  use GenServer

  # client API

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def put(item) do
    GenServer.cast(__MODULE__, {:put, item})
    {:ok, item}
  end

  def pop() do
    item = GenServer.call(__MODULE__, :pop)
    {:ok, item}
  end

  # server callbacks

  @impl true
  def init(initial_stack) do
    # TODO: update initial state
    {:ok, %{stack: initial_stack}}
  end

  @impl true
  def handle_cast({:put, item}, %{stack: stack} = state) do
    new_stack = [item | stack]
    {:noreply, %{state | stack: new_stack}}
  end

  @impl true
  def handle_call(:pop, _from, %{stack: stack} = state) do
    [item | new_stack] = stack
    {:reply, item, %{state | stack: new_stack}}
  end
end
