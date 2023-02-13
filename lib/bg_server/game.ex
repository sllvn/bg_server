defmodule BgServer.Game do
  use GenServer
  alias BgServer.{Board, Turn}

  @empty_game %{board: %Board{}, current_player: :black, turn: %Turn{}}

  defstruct [:id, state: @empty_game]

  # client API

  def start_link(_empty_opts = []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_game_state() do
    state = GenServer.call(__MODULE__, :current_state)
    {:ok, state}
  end

  def reset_game() do
    new_state =
      GenServer.call(
        __MODULE__,
        {:update_state, :board, %Board{}, turn: %Turn{}, current_player: :black}
      )

    {:ok, new_state}
  end

  def roll_dice(new_dice \\ {Enum.random(1..6), Enum.random(1..6)}) do
    {:ok, %{turn: turn}} = get_game_state()

    new_turn = Turn.roll_dice(turn, new_dice)
    new_state = GenServer.call(__MODULE__, {:update_state, turn: new_turn})

    {:ok, new_state}
  end

  def move_piece(possible_move) do
    {:ok, %{turn: turn}} = get_game_state()

    new_turn = Turn.move_piece(turn, possible_move)
    new_state = GenServer.call(__MODULE__, {:update_state, turn: new_turn})

    {:ok, new_state}
  end

  def set_pending_piece(position) do
    {:ok, %{turn: turn}} = get_game_state()

    new_turn = Turn.set_pending_piece(turn, position)
    new_state = GenServer.call(__MODULE__, {:update_state, turn: new_turn})

    {:ok, new_state}
  end

  def undo_pending_move() do
    {:ok, %{turn: turn}} = get_game_state()

    new_turn = Turn.undo_pending_move(turn)
    new_state = GenServer.call(__MODULE__, {:update_state, turn: new_turn})

    {:ok, new_state}
  end

  def commit_move() do
    {:ok, %{board: board, turn: turn}} = get_game_state()

    new_board = Board.commit_turn(board, turn)
    new_turn = %Turn{player: if(turn.player == :black, do: :white, else: :black)}

    new_state = GenServer.call(__MODULE__, {:update_state, turn: new_turn, board: new_board})

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
