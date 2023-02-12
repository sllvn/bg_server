defmodule BgServer.Board do
  alias BgServer.Turn

  defstruct points: %{
              1 => %{white: 2},
              2 => %{},
              3 => %{},
              4 => %{},
              5 => %{},
              6 => %{black: 5},
              7 => %{},
              8 => %{black: 3},
              9 => %{},
              10 => %{},
              11 => %{},
              12 => %{white: 5},
              13 => %{black: 5},
              14 => %{},
              15 => %{},
              16 => %{},
              17 => %{white: 3},
              18 => %{},
              19 => %{white: 5},
              20 => %{},
              21 => %{},
              22 => %{},
              23 => %{},
              24 => %{black: 2}
            },
            bar: %{}

  def commit_turn(board = %__MODULE__{}, turn = %Turn{}) do
    new_points =
      turn.pending_moves
      |> Enum.reduce(board.points, fn {dice_value, original_position}, points ->
        new_position = original_position - dice_value
        current_position_count = Map.get(points, original_position) |> Map.get(turn.player)
        new_position_count = Map.get(points, new_position, %{}) |> Map.get(turn.player, 0)

        updates =
          %{}
          |> Map.put(original_position, Map.put(%{}, turn.player, current_position_count - 1))
          |> Map.put(new_position, Map.put(%{}, turn.player, new_position_count + 1))

        Map.merge(points, updates)
      end)

    %__MODULE__{board | points: new_points}
  end
end
