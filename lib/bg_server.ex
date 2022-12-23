defmodule BgServer do
  @pubsub BgServer.PubSub

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, topic("test1234"))
  end

  def connect_to_game(_game_id) do
    GameState.start_link()

    {:ok, state} = GameState.get_game_state()
    state
  end

  def roll_dice do
    new_dice = {Enum.random(1..6), Enum.random(1..6)}
    {:ok, new_game_state} = GameState.set_dice_roll(new_dice)
    Phoenix.PubSub.broadcast(@pubsub, topic("test1234"), {:new_game_state, new_game_state})
  end

  def reset_game do
    {:ok, new_game_state} = GameState.reset_game()
    Phoenix.PubSub.broadcast(@pubsub, topic("test1234"), {:new_game_state, new_game_state})
  end

  def move_piece(possible_move, board, active_position) do
    IO.inspect({possible_move, board, active_position}, label: "move_piece")

    # move a piece from active_position to possible_move
    # track in pending_move

    next_board =
      board
      |> Map.update(possible_move, %{black: 1}, fn existing -> %{black: existing.black + 1} end)
      |> Map.update(active_position, %{}, fn existing -> %{black: existing.black - 1} end)

    {:ok, new_game_state} = GameState.set_board(next_board)
    Phoenix.PubSub.broadcast(@pubsub, topic("test1234"), {:new_game_state, new_game_state})
  end

  defp topic(game_id), do: "game:#{game_id}"
end
