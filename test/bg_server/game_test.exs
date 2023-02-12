defmodule BgServer.GameTest do
  use ExUnit.Case

  alias BgServer.{Board,Game,Turn}

  setup do
    %{game: start_supervised!(BgServer.Game)}
  end

  def move_piece(start_point, end_point) do
    Game.set_pending_piece(start_point)
    Game.move_piece(end_point)
  end

  test "updates the board after each players' turn", %{game: _game_pid} do
    # black's turn
    {:ok, game} = Game.get_game_state()
    assert game.turn == %Turn{}

    {:ok, game} = Game.roll_dice({2, 2})
    assert game.board == %Board{}
    assert game.turn.player == :black
    assert game.turn.dice_roll == {2,2}

    for _ <- 1..4, do: move_piece(6, 4) # move 4 black checkers from 6 to 4

    {:ok, game} = Game.commit_move()

    assert game.board.points[4] == %{black: 4}
    assert game.board.points[6] == %{black: 1}
    assert game.turn.player == :white

    # white's turn
    {:ok, game} = Game.get_game_state()
    assert game.turn == %Turn{player: :white}

    {:ok, game} = Game.roll_dice({3, 5})
    assert game.turn.player == :white
    assert game.turn.dice_roll == {3,5}

    move_piece(19, 22)
    move_piece(17, 22)

    {:ok, game} = Game.commit_move()

    assert game.board.points[19] == %{white: 4}
    assert game.board.points[17] == %{white: 2}
    assert game.board.points[22] == %{white: 2}
    assert game.turn.player == :black
  end

  describe "valid moves" do
    test "allows moving onto unoccupied + self-occupied points", %{game: _game_pid} do
      {:ok, _game} = Game.roll_dice({2, 5})

      move_piece(8, 3) # empty point
      move_piece(8, 6) # self-occupied point
      Game.commit_move()

      {:ok, game} = Game.get_game_state()
      assert game.board.points[8] == %{black: 1}
      assert game.board.points[3] == %{black: 1}
      assert game.board.points[6] == %{black: 6}
    end

    test "allows moving the same checker twice" do
      {:ok, _game} = Game.roll_dice({3, 3})

      move_piece(8, 5) # empty point
      move_piece(5, 2) # second move of that same checker
      Game.commit_move()

      {:ok, game} = Game.get_game_state()
      assert game.board.points[8] == %{black: 2}
      assert game.board.points[2] == %{black: 1}
    end
  end

  describe "invalid moves" do
    @describetag :skip
    test "only allows moving a distance shown on dice", do: :not_implemented
    test "prevents moving the wrong direction", do: :not_implemented
    test "prevents moving onto opponent-fortified points", do: :not_implemented
    test "prevents moving beyond edge of board", do: :not_implemented
  end

  describe "completing a move" do
    @describetag :skip
    test "allows completing a valid move (2-move case)", do: :not_implemented
    test "allows completing a valid move (4-move case)", do: :not_implemented

    # TODO: end game scenarios, eg, no possible move (or 1 possible move), bear-off, etc.
    test "end game scenarios", do: :not_implemented
  end

  @tag :skip
  test "capturing opponent pieces", do: :not_implemented
end
