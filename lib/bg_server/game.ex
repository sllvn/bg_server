defmodule BgServer.Game do
  use GenServer

  alias BgServer.{Turn, Board}

  @empty_game %{
    # board: %Board{},
    board: Board.empty_board(),
    current_player: :black,
    turn: %Turn{}
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

  def reset_game() do
    GenServer.call(__MODULE__, {:set, :current_player, :black})
    GenServer.call(__MODULE__, {:set, :turn, %Turn{}})
    new_state = GenServer.call(__MODULE__, {:set, :board, @empty_game.board})

    {:ok, new_state}
  end

  def roll_dice(new_dice \\ {Enum.random(1..6), Enum.random(1..6)}) do
    {:ok, %{turn: turn}} = get_game_state()

    new_turn = Turn.roll_dice(turn, new_dice)
    new_state = GenServer.call(__MODULE__, {:set, :turn, new_turn})

    {:ok, new_state}
  end

  def move_piece(possible_move) do
    {:ok, %{turn: turn}} = get_game_state()

    new_turn = Turn.move_piece(turn, possible_move)
    new_state = GenServer.call(__MODULE__, {:set, :turn, new_turn})

    {:ok, new_state}
  end

  def set_pending_piece(position) do
    {:ok, %{turn: turn}} = get_game_state()

    new_turn = Turn.set_pending_piece(turn, position)
    new_state = GenServer.call(__MODULE__, {:set, :turn, new_turn})

    {:ok, new_state}
  end

  def undo_pending_move() do
    {:ok, %{turn: turn}} = get_game_state()

    new_turn = Turn.undo_pending_move(turn)
    new_state = GenServer.call(__MODULE__, {:set, :turn, new_turn})

    {:ok, new_state}
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
      player:
        if turn.player == :black do
          :white
        else
          :black
        end,
      pending_piece: nil,
      dice_roll: {nil, nil},
      pending_moves: []
    }

    GenServer.call(__MODULE__, {:set, :board, new_board})
    new_state = GenServer.call(__MODULE__, {:set, :turn, new_turn})

    {:ok, new_state}
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
