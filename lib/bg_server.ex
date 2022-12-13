defmodule BgServer do
  @pubsub BgServer.PubSub

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, topic("test1234"))
  end

  def roll_dice do
    new_dice = {Enum.random(1..6), Enum.random(1..6)}
    Phoenix.PubSub.broadcast(@pubsub, topic("test1234"), {:dice_rolled, new_dice})
  end

  def reset_game do
    Phoenix.PubSub.broadcast(@pubsub, topic("test1234"), {:game_reset})
  end

  def move_piece(possible_move, positioned_pieces, active_position) do
    IO.inspect(possible_move, label: "move_piece")

    # move a piece from active_position to possible_move
    # track in pending_move

    next_positioned_pieces =
      positioned_pieces
      |> Map.update(possible_move, %{black: 1}, fn existing -> %{black: existing.black + 1} end)
      |> Map.update(active_position, %{}, fn existing -> %{black: existing.black - 1} end)

    Phoenix.PubSub.broadcast(@pubsub, topic("test1234"), {:piece_moved, next_positioned_pieces})
  end

  defp topic(game_id), do: "game:#{game_id}"
end
