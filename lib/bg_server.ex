defmodule BgServer do
  @pubsub BgServer.PubSub
  alias BgServer.Game

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, topic("my-game-id"))
  end

  def connect_to_game(_game_id) do
    Game.start_link()

    {:ok, state} = Game.get_game_state()
    state
  end

  def roll_dice do
    {:ok, new_game_state} = Game.roll_dice()
    Phoenix.PubSub.broadcast(@pubsub, topic("my-game-id"), {:new_game_state, new_game_state})
  end

  def reset_game do
    {:ok, new_game_state} = Game.reset_game()
    Phoenix.PubSub.broadcast(@pubsub, topic("my-game-id"), {:new_game_state, new_game_state})
  end

  def move_piece(possible_move) do
    {:ok, new_game_state} = Game.move_piece(possible_move)
    Phoenix.PubSub.broadcast(@pubsub, topic("my-game-id"), {:new_game_state, new_game_state})
  end

  def set_pending_piece(position) do
    {:ok, new_game_state} = Game.set_pending_piece(position)
    Phoenix.PubSub.broadcast(@pubsub, topic("my-game-id"), {:new_game_state, new_game_state})
  end

  def undo_pending_move() do
    {:ok, new_game_state} = Game.undo_pending_move()
    Phoenix.PubSub.broadcast(@pubsub, topic("my-game-id"), {:new_game_state, new_game_state})
  end

  defp topic(game_id), do: "game:#{game_id}"
end
