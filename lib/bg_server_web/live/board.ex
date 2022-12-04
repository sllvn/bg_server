defmodule BgServerWeb.Board do
  use BgServerWeb, :live_view

  def mount(_params, _session, socket) do
    # pieces = %{ white: [1, 1, 1, 1, 1], black: [24, 24, 24, 24, 24]}
    positioned_pieces = %{
      1  => %{white: 5},
      12 => %{white: 2},
      18 => %{white: 5},
      20 => %{white: 3},
      24 => %{black: 5},
      13 => %{black: 2},
      7  => %{black: 5},
      5  => %{black: 3},
    }

    {:ok, assign(socket, positioned_pieces: positioned_pieces)}
  end

  defp cx_for_position(position) do
    base = if position <= 12 do
      (position - 1) * 100 + 50
    else
      ((25 - position) - 1) * 100 + 50
    end
    bar_offset = if position <= 6 or position >= 19 do
      0
    else
      50
    end
    base + bar_offset
  end

  defp pieces_at_position(positioned_pieces, position, color) do
    positioned_pieces |> IO.inspect |> Map.get(position, %{}) |> IO.inspect |> Map.get(color, 0)
  end

  defp cy_for_position(position, index, positioned_pieces, color) do
    # _pieces_at_position = pieces_at_position(positioned_pieces, position, color)
    if position <= 12 do
      (index - 1) * 70 + 35
    else
      800 - ((index - 1) * 70 + 35)
    end
  end
end
