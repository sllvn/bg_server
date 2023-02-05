defmodule BgServer.GameTest do
  use ExUnit.Case

  alias BgServer.{Game,Turn}

  setup do
    game = start_supervised!(BgServer.Game)
    %{game: game}
  end

  @empty_board %{
    1 => %{white: 2}, 12 => %{white: 5}, 17 => %{white: 3}, 19 => %{white: 5},
    6 => %{black: 5}, 8 => %{black: 3}, 13 => %{black: 5}, 24 => %{black: 2}
  }
  @empty_turn %Turn{player: :black, pending_piece: nil, dice_roll: {}, pending_moves: []}

  test "updates the board after both players take a turn", %{game: _game_pid} do
    # black's turn
    {:ok, game} = Game.get_game_state()
    assert game.board == @empty_board
    assert game.turn.player == :black
    assert game.turn.dice_roll == {2,2}

    Game.set_pending_piece(6)
    Game.move_piece(4)
    Game.set_pending_piece(6)
    Game.move_piece(4)
    Game.set_pending_piece(6)
    Game.move_piece(4)

    {:ok, game} = Game.commit_move()

    assert game.board[4] == %{black: 4}
    assert game.board[6] == %{black: 1}
    assert game.turn.player == :white

    # white's turn
    {:ok, game} = Game.roll_dice({3, 5}) # TODO: replace this using mox library
    assert game.turn.player == :white
    assert game.turn.dice_roll == {3,5}

    Game.set_pending_piece(19)
    Game.move_piece(22)
    Game.set_pending_piece(17)
    Game.move_piece(22)

    {:ok, game} = Game.commit_move()

    assert game.board[19] == %{white: 4}
    assert game.board[17] == %{white: 2}
    assert game.board[22] == %{white: 2}
    assert game.turn.player == :black
  end
end
