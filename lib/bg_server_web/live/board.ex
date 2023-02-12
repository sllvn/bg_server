defmodule BgServerWeb.Board do
  use BgServerWeb, :live_view
  alias BgServer.Turn

  def mount(_params, _session, socket) do
    game = BgServer.connect_to_game(:some_game_id)
    if connected?(socket), do: BgServer.subscribe()

    %{board: board, current_player: current_player, turn: turn} = game

    {:ok,
     assign(socket,
       board: board.points,
       current_player: current_player,
       turn: turn
     )}
  end

  def handle_event("set_pending_piece", %{"position" => position}, socket) do
    click_position = String.to_integer(position)
    BgServer.set_pending_piece(click_position)
    {:noreply, socket}
  end

  def handle_event("move_pending_piece", %{"possible-move" => possible_move}, socket) do
    possible_move = String.to_integer(possible_move)
    BgServer.move_piece(possible_move)
    {:noreply, socket}
  end

  def handle_event("reset_game", _value, socket) do
    BgServer.reset_game()
    {:noreply, socket}
  end

  def handle_event("roll_dice", _value, socket) do
    BgServer.roll_dice()
    {:noreply, socket}
  end

  def handle_event("undo_pending_move", _value, socket) do
    BgServer.undo_pending_move()
    {:noreply, socket}
  end

  def handle_event("commit_move", _value, socket) do
    BgServer.commit_move()
    {:noreply, socket}
  end

  def handle_info({:new_game_state, new_game_state}, socket) do
    %{board: board, current_player: current_player, turn: turn} = new_game_state

    {:noreply,
     assign(socket,
       board: board.points,
       turn: turn,
       current_player: current_player
     )}
  end

  # view helpers

  defp cx_for_position(position) do
    base =
      if position <= 12 do
        (position - 1) * 100 + 50
      else
        (25 - position - 1) * 100 + 50
      end

    bar_offset = if position <= 6 or position >= 19, do: 0, else: 50

    base + bar_offset
  end

  defp cy_for_position(position, index) do
    if position <= 12 do
      800 - ((index - 1) * 70 + 35)
    else
      (index - 1) * 70 + 35
    end
  end

  defp cy_for_position(position, board, turn, :include_pending) do
    current_pieces =
      board
      |> Map.get(position, %{})
      |> Map.get(turn.player, 0)

    moved_pieces =
      turn.pending_moves
      |> Enum.filter(fn {_dice_value, original_position} -> original_position == position end)
      |> length

    pending_pieces =
      turn.pending_moves
      |> Enum.filter(fn {dice_value, original_position} -> original_position - dice_value == position end)
      |> length

    cy_for_position(position, current_pieces + pending_pieces + 1 - moved_pieces)
  end

  defp cy_for_position(position, board, turn, index) do
    # {position, board, turn.pending_moves, index} |> IO.inspect(label: "cy_for_position/3")

    moved_pieces =
      turn.pending_moves
      |> Enum.filter(fn {_dice_value, original_position} -> original_position == position end)
      |> length

    current_pieces =
      board
      |> Map.get(position, %{})
      |> Map.get(turn.player, 0)

    cy_for_position(position, current_pieces + 1 + index - moved_pieces)
  end

  defp classes_for_piece(index, position, color, board, turn = %Turn{}) do
    num_pieces = pieces_at_position(board, turn, position, color)

    cond do
      turn.pending_piece == position and index == num_pieces -> "final active"
      index == num_pieces -> "final"
      true -> nil
    end
  end

  defp indexify(enumerable) do
    Enum.with_index(enumerable, fn element, index -> {index, element} end)
  end

  # business logic

  defp can_roll_dice(dice_roll), do: elem(dice_roll, 0) == nil

  defp pieces_at_position(board, turn = %Turn{}, position, color) do
    # list of tuples {amount, original_position}
    moved_from_position =
      turn.pending_moves
      |> Enum.filter(fn move -> elem(move, 1) == position end)
      |> Enum.count()

    board_at_position =
      board
      |> Map.get(position, %{})
      |> Map.get(color, 0)

    board_at_position - moved_from_position
  end

  defp possible_moves(_board, %{pending_piece: nil}), do: []

  defp possible_moves(board, turn) do
    remaining_actions(turn)
    |> Enum.map(fn roll -> turn.pending_piece - roll end)
    |> Enum.filter(fn c -> is_valid_move(c, board, turn.player) end)
  end

  defp is_valid_move(candidate_position, board, current_player) do
    opponent = if current_player == :black, do: :white, else: :black

    opponent_pieces_at_position =
      board
      |> Map.get(candidate_position, %{})
      |> Map.get(opponent, 0)

    opponent_pieces_at_position == 0
  end

  defp remaining_actions(turn) do
    %{dice_roll: dice_roll, pending_moves: pending_moves} = turn
    all_moves = all_moves_for_roll(dice_roll)
    consumed_moves = Enum.map(pending_moves, &elem(&1, 0))
    all_moves -- consumed_moves
  end

  def all_moves_for_roll({nil, nil}), do: []
  def all_moves_for_roll({a, b}) do
    if a == b and a != nil, do: [a, a, a, a], else: [a, b]
  end

  defp is_move_complete(turn) do
    length(remaining_actions(turn)) == 0
  end

  defp grouped_pending_moves(_board, turn) do
    turn.pending_moves
    |> Enum.reduce(%{}, fn {dice_value, original_position}, acc ->
      target_position = original_position - dice_value
      existing_pending = Map.get(acc, target_position, [])
      Map.put(acc, target_position, existing_pending ++ [{dice_value, original_position}])
    end)
    |> IO.inspect(label: "grouped_pending_moves")
  end
end
