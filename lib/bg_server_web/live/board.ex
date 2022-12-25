defmodule BgServerWeb.Board do
  use BgServerWeb, :live_view

  def mount(_params, _session, socket) do
    game = BgServer.connect_to_game(:some_game_id)
    if connected?(socket), do: BgServer.subscribe()

    %{board: board, active_player: active_player, turn: turn} = game

    {:ok,
     assign(socket,
       board: board,
       active_player: active_player,
       turn: turn
     )}
  end

  def handle_event("set_pending_piece", value, socket) do
    click_position = String.to_integer(value["position"])
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

  def handle_info({:new_game_state, new_game_state}, socket) do
    %{board: board, active_player: active_player, turn: turn} = new_game_state

    {:noreply,
     assign(socket,
       board: board,
       turn: turn,
       active_player: active_player
     )}
  end

  defp cx_for_position(position) do
    base =
      if position <= 12 do
        (position - 1) * 100 + 50
      else
        (25 - position - 1) * 100 + 50
      end

    bar_offset =
      if position <= 6 or position >= 19 do
        0
      else
        50
      end

    base + bar_offset
  end

  defp pieces_at_position(board, position, color) do
    board
    |> Map.get(position, %{})
    |> Map.get(color, 0)
  end

  defp cy_for_position(position, index) do
    if position <= 12 do
      800 - ((index - 1) * 70 + 35)
    else
      (index - 1) * 70 + 35
    end
  end

  defp cy_for_position(position, board, player) do
    # used for candidate moves
    current_pieces = board |> Map.get(position, %{}) |> Map.get(player, 0)
    cy_for_position(position, current_pieces + 1)
  end

  defp classes_for_piece(index, position, color, board, active_position) do
    num_pieces = pieces_at_position(board, position, color)

    cond do
      active_position == position and index == num_pieces -> "final active"
      index == num_pieces -> "final"
      true -> nil
    end
  end

  defp possible_moves(nil, _dice_roll, _board), do: []

  defp possible_moves(position, dice_roll, board) do
    dice_roll
    |> Tuple.to_list()
    |> Enum.map(fn roll -> position - roll end)
    |> Enum.filter(fn c -> is_valid_move(c, board, :black) end)
  end

  defp is_valid_move(candidate_position, board, current_player) do
    opponent = if current_player == :black, do: :white, else: :black

    opponent_pieces_at_position =
      board
      |> Map.get(candidate_position, %{})
      |> Map.get(opponent, 0)

    opponent_pieces_at_position == 0
  end
end
