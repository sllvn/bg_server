defmodule Game do
  use GenServer

  @initial_state %{
    board: %{
      1 => %{white: 2}, 12 => %{white: 5}, 17 => %{white: 3}, 19 => %{white: 5},
      6 => %{black: 5}, 8 => %{black: 3}, 13 => %{black: 5}, 24 => %{black: 2}
    },
    active_player: :black,
    turn: %{
      player: :black,
      pending_piece: nil,
      dice_roll: {2,6},
      pending_moves: [], # a list of {original,ending} or {dice_value,original,ending} tuples
    }
  }

  # client API

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_game_state() do
    state = GenServer.call(__MODULE__, :current_state)
    {:ok, state}
  end

  def roll_dice() do
    new_dice = {Enum.random(1..6), Enum.random(1..6)}
    new_state = set_turn(:dice_roll, new_dice)
    {:ok, new_state}
  end

  def move_piece(possible_move) do
    # board, active_position
    {:ok, %{board: board, turn: turn}} = get_game_state()

    next_board =
      board
      |> Map.update(possible_move, %{black: 1}, fn existing -> %{black: existing.black + 1} end)
      |> Map.update(turn.pending_piece, %{}, fn existing -> %{black: existing.black - 1} end)

    set_turn(:pending_piece, nil)
    new_state = GenServer.call(__MODULE__, {:set, :board, next_board})
    {:ok, new_state}
  end

  def reset_game() do
    %{board: board, active_player: active_player, turn: turn} = @initial_state

    GenServer.call(__MODULE__, {:set, :active_player, active_player})
    GenServer.call(__MODULE__, {:set, :turn, turn})
    new_state = GenServer.call(__MODULE__, {:set, :board, board})

    {:ok, new_state}
  end

  def set_pending_piece(position) do
    {:ok, %{turn: turn}} = get_game_state()

    new_pending_piece =
      cond do
        position == turn.pending_piece -> nil
        true -> position
      end

    new_state = set_turn(:pending_piece, new_pending_piece)
    {:ok, new_state}
  end

  # convenience functions

  defp set_turn(key, value) do
    {:ok, %{turn: turn}} = get_game_state()
    new_turn = Map.put(turn, key, value)
    GenServer.call(__MODULE__, {:set, :turn, new_turn})
  end

  # server callbacks

  @impl true
  def init(_initial_state) do
    {:ok, @initial_state}
  end

  @impl true
  def handle_call({:set, key, value}, _from, state) do
    new_state = Map.put(state, key, value)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:current_state, _from, state) do
    {:reply, state, state}
  end
end
