defmodule BgServer.BoardTest do
  use ExUnit.Case

  alias BgServer.{Board,Turn}

  describe "commit_move (valid moves)" do
    test "allows moving to an unoccupied point" do
      turn = %Turn{pending_moves: [{2,6}, {4,8}], player: :black}
      new_board = Board.commit_turn(%Board{}, turn)

      assert new_board.points[4] == %{black: 2}
      assert new_board.points[6] == %{black: 4}
      assert new_board.points[8] == %{black: 2}
    end

    test "allows moving to a self-occupied point" do
      turn = %Turn{pending_moves: [{2,8}, {2,8}], player: :black}
      new_board = Board.commit_turn(%Board{}, turn)

      assert new_board.points[6] == %{black: 7}
      assert new_board.points[8] == %{black: 1}
    end

    test "allows moving the same checker twice" do
      turn = %Turn{pending_moves: [{3,8}, {2,5}], player: :black}
      new_board = Board.commit_turn(%Board{}, turn)

      assert new_board.points[3] == %{black: 1}
      assert new_board.points[8] == %{black: 2}
    end
  end

  describe "commit_move (invalid moves)" do
    @describetag :skip
    test "only allows moving a distance shown on dice", do: :not_implemented
    test "prevents moving the wrong direction", do: :not_implemented
    test "prevents moving onto opponent-fortified points", do: :not_implemented
    test "prevents moving beyond edge of board", do: :not_implemented
  end

  describe "commit_move (capturing pieces)" do
    @describetag :skip
    test "allows capturing bare opponent pieces", do: :not_implemented
    test "does not allow capturing doubled up opponent pieces", do: :not_implemented
  end
end
