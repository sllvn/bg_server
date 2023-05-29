defmodule BgServer.Board do
  alias BgServer.Turn

  defstruct points: %{
              1 => {:white, 2},
              2 => nil,
              3 => nil,
              4 => nil,
              5 => nil,
              6 => {:black, 5},
              7 => nil,
              8 => {:black, 3},
              9 => nil,
              10 => nil,
              11 => nil,
              12 => {:white, 5},
              13 => {:black, 5},
              14 => nil,
              15 => nil,
              16 => nil,
              17 => {:white, 3},
              18 => nil,
              19 => {:white, 5},
              20 => nil,
              21 => nil,
              22 => nil,
              23 => nil,
              24 => {:black, 2}
            },
            bar: %{}

  # TODO: is_turn_valid should live on turn?
  def commit_turn(board = %__MODULE__{}, turn = %Turn{}) do
    # if any piece is left on the bar, and any of the moves were not bar -> board, the turn is invalid
    is_turn_valid =
      turn.pending_moves
      |> Enum.reduce(true, fn {dice_value, original_position}, all_valid ->
        target_position = apply_dice(original_position, dice_value, turn.player)
        all_valid && is_valid_move(target_position, board.points, turn.player)
      end)

    if is_turn_valid do
      new_board = Enum.reduce(turn.pending_moves, board, &move_piece(&1, &2, turn))
      {:ok, new_board}
    else
      {:error}
    end
  end

  def move_piece({dice_value, original_position}, board, turn = %Turn{}) do
    target_position = apply_dice(original_position, dice_value, turn.player)

    current_position_count = num_pieces_at(board.points, original_position, turn.player)
    new_position_count = num_pieces_at(board.points, target_position, turn.player)

    opponent = Turn.next_player(turn.player)

    is_capturing = num_pieces_at(board.points, target_position, opponent) == 1

    new_bar =
      if is_capturing do
        board.bar |> Map.put(opponent, Map.get(board.bar, opponent, 0) + 1)
      else
        board.bar
      end

    points_updates =
      %{}
      |> Map.put(original_position, {turn.player, current_position_count - 1})
      |> Map.put(target_position, {turn.player, new_position_count + 1})
      |> Enum.map(fn {k, v} -> if v == 0, do: nil, else: {k, v} end) # clean out points with 0s
      |> Enum.into(%{})

    %__MODULE__{
      points: Map.merge(board.points, points_updates),
      bar: new_bar
    }
  end

  def num_pieces_at(points = %{}, position, player) do
    case Map.get(points, position) do
      {^player, count} -> count
      _ -> 0
    end
  end

  def apply_dice(position, dice_value, :black), do: position - dice_value
  def apply_dice(position, dice_value, :white), do: position + dice_value

  def possible_moves(_board = %__MODULE__{}, %{pending_piece: nil}), do: []

  def possible_moves(_board = %__MODULE__{}, %{
        pending_piece: :bar,
        dice_roll: dice_roll,
        player: player
      }) do
    # TODO: NEXT: finish this + wire up rendering the pending bar piece
    # TODO: wire up moving piece from bar
    {a, b} = dice_roll

    if player == :white do
      [25 - a, 25 - b]
    else
      [a, b]
    end
  end

  def possible_moves(board = %__MODULE__{}, turn = %Turn{}) do
    Turn.remaining_actions(turn)
    |> Enum.map(fn roll -> apply_dice(turn.pending_piece, roll, turn.player) end)
    |> Enum.filter(fn c -> is_valid_move(c, board.points, turn.player) end)
  end

  defp is_valid_move(candidate_position, points, current_player) do
    opponent = Turn.next_player(current_player)
    opponent_pieces_at_position = num_pieces_at(points, candidate_position, opponent)
    opponent_pieces_at_position <= 1
  end

  def pieces_at_position(board = %__MODULE__{}, turn = %Turn{}, position, color) do
    # list of tuples {amount, original_position}
    moved_from_position =
      turn.pending_moves
      |> Enum.filter(fn move -> elem(move, 1) == position end)
      |> Enum.count()

    points_at_position = num_pieces_at(board.points, position, color)

    points_at_position - moved_from_position
  end
end
