defmodule BgServer.Game do
  use GenServer
  alias BgServer.{Board, Turn}

  @empty_game %{board: %Board{}, current_player: :black, turn: %Turn{}}

  defstruct [:id, state: @empty_game]

  # client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_game_state() do
    state = GenServer.call(__MODULE__, :current_state)
    {:ok, state}
  end

  def reset_game(), do: update_state(fn _ -> @empty_game end)

  def roll_dice(new_dice \\ {Enum.random(1..6), Enum.random(1..6)}),
    do: update_state(fn %{turn: turn} -> %{turn: Turn.roll_dice(turn, new_dice)} end)

  def move_piece(possible_move),
    do: update_state(fn %{turn: turn} -> %{turn: Turn.move_piece(turn, possible_move)} end)

  def set_pending_piece(position),
    do: update_state(fn %{turn: turn} -> %{turn: Turn.set_pending_piece(turn, position)} end)

  def undo_pending_move(),
    do: update_state(fn %{turn: turn} -> %{turn: Turn.undo_pending_move(turn)} end)

  def commit_move() do
    update_state(fn %{turn: turn, board: board} ->
      %{
        board: Board.commit_turn(board, turn),
        turn: %Turn{player: if(turn.player == :black, do: :white, else: :black)}
      }
    end)
  end

  defp update_state(updater_fn) do
    {:ok, old_state} = get_game_state()
    new_state = GenServer.call(__MODULE__, {:update_state, updater_fn.(old_state)})
    {:ok, new_state}
  end

  # server callbacks

  @impl true
  def init(_initial_state) do
    {:ok, @empty_game}
  end

  @impl true
  def handle_call({:update_state, updates}, _from, state) do
    new_state = Enum.reduce(updates, state, fn {k, v}, acc -> Map.put(acc, k, v) end)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:current_state, _from, state) do
    {:reply, state, state}
  end
end
