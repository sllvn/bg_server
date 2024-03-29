defmodule BgServer.Turn do
  alias BgServer.Board

  # pending_moves is a list of {dice_roll, start_position} tuples
  defstruct player: :black, pending_piece: nil, dice_roll: {nil, nil}, pending_moves: []

  def move_piece(turn = %__MODULE__{}, possible_move) do
    original_position = turn.pending_piece
    dice_roll = calculate_distance(original_position, possible_move, turn.player)

    %__MODULE__{
      turn
      | pending_moves: [{dice_roll, original_position} | turn.pending_moves] |> Enum.reverse(),
        pending_piece: nil
    }
  end

  def roll_dice(turn = %__MODULE__{}, new_dice \\ {Enum.random(1..6), Enum.random(1..6)}) do
    %__MODULE__{turn | dice_roll: new_dice}
  end

  # TODO: similar to Board.apply_dice/3, where should these helpers live?
  def calculate_distance(:bar, end_pos, :black), do: 25 - end_pos
  def calculate_distance(:bar, end_pos, :white), do: end_pos
  def calculate_distance(start_pos, end_pos, :black), do: start_pos - end_pos
  def calculate_distance(start_pos, end_pos, :white), do: end_pos - start_pos

  def next_player(:black), do: :white
  def next_player(:white), do: :black

  def set_pending_piece(turn = %__MODULE__{}, position) do
    new_pending_piece =
      cond do
        position == turn.pending_piece -> nil
        true -> position
      end

    %__MODULE__{turn | pending_piece: new_pending_piece}
  end

  def undo_pending_move(turn = %__MODULE__{}) do
    new_pending_moves =
      case turn.pending_moves do
        [] -> []
        [_ | remaining_moves] -> remaining_moves
      end

    %__MODULE__{turn | pending_moves: new_pending_moves}
  end

  def remaining_actions(turn = %__MODULE__{}) do
    %{dice_roll: dice_roll, pending_moves: pending_moves} = turn
    all_moves = all_moves_for_roll(dice_roll)
    consumed_moves = Enum.map(pending_moves, &elem(&1, 0))
    all_moves -- consumed_moves
  end

  def is_complete(turn = %__MODULE__{}) do
    length(remaining_actions(turn)) == 0
  end

  def all_moves_for_roll({nil, nil}), do: []
  def all_moves_for_roll({a, a}), do: [a, a, a, a]
  def all_moves_for_roll({a, b}), do: [a, b]

  def validate(turn = %__MODULE__{}, board = %Board{}) do
    pending_moves_valid =
      turn.pending_moves
      |> Enum.reduce(true, fn {dice_value, original_position}, all_valid ->
        target_position = Board.apply_dice(original_position, dice_value, turn.player)
        all_valid && Board.is_valid_move(target_position, board.points, turn.player)
      end)

    required_bar_moves = min(length(all_moves_for_roll(turn.dice_roll)), board.bar[turn.player] || 0)
    bar_moves = Enum.count(turn.pending_moves, fn {_dice_roll, original_position} -> original_position == :bar end)
    did_exhaust_bar_moves = required_bar_moves == bar_moves

    case {pending_moves_valid, did_exhaust_bar_moves} do
      {false, _} -> {:error, {:reason, :invalid_pending_moves}}
      {_, false} -> {:error, {:reason, :pieces_left_on_bar}}
      {true, true} -> {:ok, turn}
    end
  end

end
