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

  test "updates the board after both players take a turn", %{game: game} do
    # black's turn
    {:ok, state} = Game.get_game_state()
    assert state.board == @empty_board
    assert state.turn.player == :black
    assert state.turn.dice_roll == {2,2}

    Game.set_pending_piece(6)
    Game.move_piece(4)
    Game.set_pending_piece(6)
    Game.move_piece(4)
    Game.set_pending_piece(6)
    Game.move_piece(4)

    {:ok, state} = Game.commit_move()

    assert state.board[4] == %{black: 4}
    assert state.board[6] == %{black: 1}
    assert state.turn.player == :white

    # white's turn
    {:ok, state} = Game.roll_dice({3, 5}) # TODO: replace this using mox library
    assert state.turn.player == :white
    assert state.turn.dice_roll == {3,5}

    Game.set_pending_piece(19)
    Game.move_piece(22)
    Game.set_pending_piece(17)
    Game.move_piece(22)

    {:ok, state} = Game.commit_move()
    IO.inspect(state)

    assert state.board[19] == %{white: 4}
    assert state.board[17] == %{white: 2}
    assert state.board[22] == %{white: 2}
    assert state.turn.player == :black
  end
end
