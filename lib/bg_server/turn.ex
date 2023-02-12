defmodule BgServer.Turn do
  defstruct player: :black, pending_piece: nil, dice_roll: {nil, nil}, pending_moves: []

  def move_piece(turn = %__MODULE__{}, possible_move) do
    original_position = turn.pending_piece
    dice_roll = original_position - possible_move

    %__MODULE__{
      turn
      | pending_moves: [{dice_roll, original_position} | turn.pending_moves] |> Enum.reverse(),
        pending_piece: nil
    }
  end

  def roll_dice(turn = %__MODULE__{}, new_dice \\ {Enum.random(1..6), Enum.random(1..6)}) do
    %__MODULE__{turn | dice_roll: new_dice}
  end

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
end
