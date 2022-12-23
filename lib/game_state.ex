defmodule GameState do
  use GenServer

  @initial_board_setup %{
    1 => %{white: 2},
    12 => %{white: 5},
    17 => %{white: 3},
    19 => %{white: 5},
    6 => %{black: 5},
    8 => %{black: 3},
    13 => %{black: 5},
    24 => %{black: 2}
  }
  @initial_active_player :black
  @initial_turn :black
  @initial_dice_roll {2, 6}
  @initial_state %{
    board: @initial_board_setup,
    active_player: @initial_active_player,
    turn: @initial_turn,
    dice_roll: @initial_dice_roll
  }

  # client API

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_game_state() do
    state = GenServer.call(__MODULE__, :current_state)
    {:ok, state}
  end

  def set_dice_roll(new_dice) do
    GenServer.cast(__MODULE__, {:set, :dice_roll, new_dice})
    state = GenServer.call(__MODULE__, :current_state)
    {:ok, state}
  end

  def set_board(new_board) do
    GenServer.cast(__MODULE__, {:set, :board, new_board})
    state = GenServer.call(__MODULE__, :current_state)
    {:ok, state}
  end

  def reset_game() do
    %{board: board, active_player: active_player, turn: turn, dice_roll: dice_roll} = @initial_state

    GenServer.cast(__MODULE__, {:set, :dice_roll, dice_roll})
    GenServer.cast(__MODULE__, {:set, :active_player, active_player})
    GenServer.cast(__MODULE__, {:set, :turn, turn})
    GenServer.cast(__MODULE__, {:set, :board, board})

    state = GenServer.call(__MODULE__, :current_state)
    {:ok, state}
  end

  # server callbacks

  @impl true
  def init(_initial_state) do
    {:ok, @initial_state}
  end

  @impl true
  def handle_cast({:set, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl true
  def handle_call(:current_state, _from, state) do
    {:reply, state, state}
  end
end
