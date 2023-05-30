defmodule BgServerWeb.Board do
  use BgServerWeb, :live_view
  alias BgServer.{Board, Turn}

  def mount(params, _session, socket) do
    game = BgServer.connect_to_game(:some_game_id)
    if connected?(socket), do: BgServer.subscribe()

    current_player = if params["player"] == "black", do: :black, else: :white

    %{board: board, turn: turn} = game

    {:ok, assign(socket, board: board, current_player: current_player, turn: turn)}
  end

  def handle_event("set_pending_piece", %{"position" => position}, socket) do
    click_position = String.to_integer(position)

    if are_dice_rolled(socket.assigns.turn) do
      BgServer.set_pending_piece(click_position)
    end

    {:noreply, socket}
  end

  def handle_event("move_pending_piece", %{"possible-move" => possible_move}, socket) do
    possible_move = String.to_integer(possible_move)
    BgServer.move_piece(possible_move)
    {:noreply, socket}
  end

  def handle_event("set_pending_bar_piece", _params, socket) do
    if are_dice_rolled(socket.assigns.turn) do
      BgServer.set_pending_piece(:bar)
    end

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
    %{board: board, turn: turn} = new_game_state

    {:noreply, assign(socket, board: board, turn: turn)}
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

  defp cy_for_bar_piece(index, :black), do: 340 - (index-1) * 75
  defp cy_for_bar_piece(index, :white), do: 460 + (index-1) * 75

  defp cy_for_position(position, index) do
    if position <= 12 do
      800 - ((index - 1) * 70 + 35)
    else
      (index - 1) * 70 + 35
    end
  end

  defp cy_for_position(position, points, turn, :include_pending) do
    current_pieces = Board.num_pieces_at(points, position, turn.player)

    moved_pieces =
      turn.pending_moves
      |> Enum.filter(fn {_dice_value, original_position} -> original_position == position end)
      |> length

    pending_pieces =
      turn.pending_moves
      |> Enum.filter(fn {dice_value, original_position} ->
        position == Board.apply_dice(original_position, dice_value, turn.player)
      end)
      |> length

    cy_for_position(position, current_pieces + pending_pieces + 1 - moved_pieces)
  end

  defp cy_for_position(position, points, turn, index) do
    # {position, board, turn.pending_moves, index} |> IO.inspect(label: "cy_for_position/3")

    moved_pieces =
      turn.pending_moves
      |> Enum.filter(fn {_dice_value, original_position} -> original_position == position end)
      |> length

    current_pieces = Board.num_pieces_at(points, position, turn.player)

    cy_for_position(position, current_pieces + 1 + index - moved_pieces)
  end

  defp classes_for_piece(index, position, color, board = %Board{}, turn = %Turn{}) do
    num_pieces = Board.pieces_at_position(board, turn, position, color)

    cond do
      turn.pending_piece == position and index == num_pieces -> "final active"
      index == num_pieces -> "final"
      true -> nil
    end
  end

  defp indexify(enumerable) do
    Enum.with_index(enumerable, fn element, index -> {index, element} end)
  end

  defp grouped_pending_moves(_board = %Board{}, turn = %Turn{}) do
    turn.pending_moves
    |> Enum.reduce(%{}, fn {dice_value, original_position}, acc ->
      target_position = Board.apply_dice(original_position, dice_value, turn.player)
      existing_pending = Map.get(acc, target_position, [])
      Map.put(acc, target_position, existing_pending ++ [{dice_value, original_position}])
    end)
  end

  # business logic

  defp can_roll_dice(dice_roll), do: elem(dice_roll, 0) == nil

  defp are_dice_rolled(turn = %Turn{}), do: !can_roll_dice(turn.dice_roll)
end
