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

    active_position = 18
    dice_roll = {3, 5}

    {:ok,
     assign(socket,
       positioned_pieces: positioned_pieces,
       active_position: active_position,
       dice_roll: dice_roll
     )}
  end

  def handle_event("set_active", value, socket) do
    IO.inspect(value)
    active_position = String.to_integer(value["position"])
    # {:ok, new_temp} = Thermostat.inc_temperature(socket.assigns.id)
    {:noreply,
     assign(socket,
       active_position: active_position
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

  defp pieces_at_position(positioned_pieces, position, color) do
    positioned_pieces
    |> Map.get(position, %{})
    |> Map.get(color, 0)
  end

  defp cy_for_position(position, index, positioned_pieces, color) do
    # _pieces_at_position = pieces_at_position(positioned_pieces, position, color)
    if position <= 12 do
      800 - ((index - 1) * 70 + 35)
    else
      (index - 1) * 70 + 35
    end
  end

  defp classes_for_piece(index, position, color, positioned_pieces, active_position) do
    num_pieces = pieces_at_position(positioned_pieces, position, color)
    cond do
      active_position == position and index == num_pieces -> "final active"
      index == num_pieces -> "final"
      true -> nil
    end
  end
end
