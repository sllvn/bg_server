defmodule BgServer.Game do
  use GenServer

  alias BgServer.Turn

  @empty_game %{
    board: %{
      1 => %{white: 2}, 12 => %{white: 5}, 17 => %{white: 3}, 19 => %{white: 5},
      6 => %{black: 5}, 8 => %{black: 3}, 13 => %{black: 5}, 24 => %{black: 2}
    },
    current_player: :black,
    turn: %Turn{
      player: :black,
      pending_piece: nil,
      dice_roll: {2, 2},
      pending_moves: [{2,6}], # a list of {dice_value, original_position} tuples
    }
  }

  defstruct [:id, state: @empty_game]

  # client API

  def start_link(opts) do
    IO.inspect(opts, label: "start_link opts")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_game_state() do
    state = GenServer.call(__MODULE__, :current_state)
    {:ok, state}
  end

  def roll_dice(new_dice \\ {Enum.random(1..6), Enum.random(1..6)}) do
    new_state = set_turn(:dice_roll, new_dice)
    {:ok, new_state}
  end

  def move_piece(possible_move) do
    {:ok, %{turn: turn}} = get_game_state()

    original_position = turn.pending_piece
    dice_roll = original_position - possible_move

    set_turn(:pending_moves, [{dice_roll, original_position} | turn.pending_moves])
    new_state = set_turn(:pending_piece, nil)

    {:ok, new_state}
  end

  def reset_game() do
    %{board: board, current_player: current_player, turn: turn} = @empty_game

    GenServer.call(__MODULE__, {:set, :current_player, current_player})
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

    {:ok, set_turn(:pending_piece, new_pending_piece)}
  end

  def undo_pending_move() do
    {:ok, %{turn: turn}} = get_game_state()

    new_pending_moves =
      case turn.pending_moves do
        [] -> []
        [_ | remaining_moves] -> remaining_moves
      end

    {:ok, set_turn(:pending_moves, new_pending_moves)}
  end

  def commit_move() do
    # TODO: apply turn to board, then reset turn and toggle turn.player
    {:ok, game_state} = get_game_state()
    %{board: board, turn: turn} = game_state

    new_board =
      turn.pending_moves
      |> Enum.reduce(board, fn {dice_value, original_position}, board ->
        new_position = original_position - dice_value
        current_position_count = Map.get(board, original_position) |> Map.get(turn.player)
        new_position_count = Map.get(board, new_position, %{}) |> Map.get(turn.player, 0)

        updates =
          %{}
          |> Map.put(original_position, Map.put(%{}, turn.player, current_position_count - 1))
          |> Map.put(new_position, Map.put(%{}, turn.player, new_position_count + 1))

        Map.merge(board, updates)
      end)

    new_turn = %Turn{
      player: if turn.player == :black do :white else :black end,
      pending_piece: nil,
      dice_roll: {nil, nil},
      pending_moves: []
    }

    GenServer.call(__MODULE__, {:set, :board, new_board})
    new_state = GenServer.call(__MODULE__, {:set, :turn, new_turn})

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
    {:ok, @empty_game}
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
