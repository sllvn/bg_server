defmodule BgServerWeb.Board do
  use BgServerWeb, :live_view

  def mount(_params, _session, socket) do
    # pieces = %{ white: [1, 1, 1, 1, 1], black: [24, 24, 24, 24, 24]}
    positioned_pieces = %{
      1 => %{white: 2},
      12 => %{white: 5},
      17 => %{white: 3},
      19 => %{white: 5},

      6 => %{black: 5},
      8 => %{black: 3},
      13 => %{black: 5},
      24 => %{black: 2},
    }

    active_player = :black # the current session's player
    turn = :black
    active_position = 8
    dice_roll = {3, 6}

    {:ok,
     assign(socket,
       positioned_pieces: positioned_pieces,
       active_player: active_player,
       turn: turn,
       active_position: active_position,
       dice_roll: dice_roll
     )}
  end

  def handle_event("set_active", value, socket) do
    click_position = String.to_integer(value["position"])
    active_position = cond do
      click_position == socket.assigns[:active_position] -> nil
      true -> click_position
    end

    {:noreply, assign(socket, active_position: active_position)}
  end

  def handle_event("move_piece", _value, _socket), do: :not_implemented
  def handle_event("undo_move_piece", _value, _socket), do: :not_implemented

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

  defp pieces_at_position(positioned_pieces, position, color) do
    positioned_pieces
    |> Map.get(position, %{})
    |> Map.get(color, 0)
  end

  defp cy_for_position(position, index, positioned_pieces) do
    if position <= 12 do
      800 - ((index - 1) * 70 + 35)
    else
      (index - 1) * 70 + 35
    end
  end

  defp cy_for_position(position, positioned_pieces) do
    # used for possible moves
    cy_for_position(position, Map.get(positioned_pieces, position, 1), positioned_pieces)
  end

  defp classes_for_piece(index, position, color, positioned_pieces, active_position) do
    num_pieces = pieces_at_position(positioned_pieces, position, color)
    cond do
      active_position == position and index == num_pieces -> "final active"
      index == num_pieces -> "final"
      true -> nil
    end
  end

  defp possible_moves(nil, _dice_roll, _positioned_pieces), do: []
  defp possible_moves(position, dice_roll, positioned_pieces) do
    IO.inspect([position, dice_roll], label: "possible_moves")
    [position - elem(dice_roll, 0), position - elem(dice_roll, 1)]
  end

  defp is_valid_move(), do: :not_implemented
end
