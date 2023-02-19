defmodule BgServer.BoardTest do
  use ExUnit.Case

  alias BgServer.{Board, Turn}

  describe "commit_turn (valid moves)" do
    test "allows moving to an unoccupied point" do
      turn = %Turn{pending_moves: [{2, 6}, {4, 8}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[4] == %{black: 2}
      assert new_board.points[6] == %{black: 4}
      assert new_board.points[8] == %{black: 2}
    end

    test "allows moving to a self-occupied point" do
      turn = %Turn{pending_moves: [{2, 8}, {2, 8}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[6] == %{black: 7}
      assert new_board.points[8] == %{black: 1}
    end

    test "allows moving the same checker twice" do
      turn = %Turn{pending_moves: [{3, 8}, {2, 5}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[3] == %{black: 1}
      assert new_board.points[8] == %{black: 2}
    end

    # TODO: move test to move_piece?
    test "moves black checkers the correct direction" do
      turn = %Turn{pending_moves: [{3, 8}, {2, 8}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[5] == %{black: 1}
      assert new_board.points[6] == %{black: 6}
      assert new_board.points[8] == %{black: 1}
    end

    # TODO: move test to move_piece?
    test "moves white checkers the correct direction" do
      turn = %Turn{pending_moves: [{3, 12}, {2, 12}], player: :white}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[12] == %{white: 3}
      assert new_board.points[14] == %{white: 1}
      assert new_board.points[15] == %{white: 1}
    end
  end

  # describe "commit_turn (invalid moves)" do
  #   test "only allows moving a distance shown on dice" do
  #     turn = %Turn{pending_moves: [{3,7}, {2,5}], player: :black}
  #     {:ok, result} = Board.commit_turn(%Board{}, turn)
  #     assert {:error, _} = result

  #     # assert new_board.points[3] == %{black: 1}
  #     # assert new_board.points[8] == %{black: 2}
  #   end

  #   @tag :skip
  #   test "prevents moving the wrong direction", do: :not_implemented

  #   @tag :skip
  #   test "prevents moving onto opponent-fortified points", do: :not_implemented

  #   @tag :skip
  #   test "prevents moving beyond edge of board", do: :not_implemented
  # end

  describe "commit_turn (capturing pieces)" do
    test "allows capturing bare opponent pieces" do
      board = %Board{points: %{%Board{}.points | 6 => %{black: 1}}}
      turn = %Turn{pending_moves: [{5, 1}, {3, 1}], player: :white}
      {:ok, new_board} = Board.commit_turn(board, turn)

      assert new_board.points[4] == %{white: 1}
      assert new_board.points[6] == %{white: 1}
    end

    @tag :wip
    test "does not allow capturing doubled up opponent pieces" do
      board = %Board{points: %{%Board{}.points | 6 => %{black: 2}}}
      turn = %Turn{pending_moves: [{5, 1}, {3, 1}], player: :white}
      assert {:error} = Board.commit_turn(board, turn)
    end
  end

  describe "move_piece" do
  end
end
