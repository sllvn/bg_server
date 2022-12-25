defmodule BgServer do
  @pubsub BgServer.PubSub

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, topic("test1234"))
  end

  # TODO: move roll_dice, reset_game, move_piece into game_state, making
  #       this BgServer module only for handling coordination between liveview process and stateful genserver

  def connect_to_game(_game_id) do
    Game.start_link()

    {:ok, state} = Game.get_game_state()
    state
  end

  def roll_dice do
    {:ok, new_game_state} = Game.roll_dice()
    Phoenix.PubSub.broadcast(@pubsub, topic("test1234"), {:new_game_state, new_game_state})
  end

  def reset_game do
    {:ok, new_game_state} = Game.reset_game()
    Phoenix.PubSub.broadcast(@pubsub, topic("test1234"), {:new_game_state, new_game_state})
  end

  def move_piece(possible_move, board, active_position) do
    {:ok, new_game_state} = Game.move_piece(possible_move, board, active_position)
    Phoenix.PubSub.broadcast(@pubsub, topic("test1234"), {:new_game_state, new_game_state})
  end

  defp topic(game_id), do: "game:#{game_id}"
end
