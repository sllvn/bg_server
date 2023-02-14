defmodule BgServer.BoardTest do
  use ExUnit.Case

  alias BgServer.{Board,Turn}

  describe "commit_move (valid moves)" do
    test "allows moving to an unoccupied point" do
      turn = %Turn{pending_moves: [{2,6}, {4,8}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[4] == %{black: 2}
      assert new_board.points[6] == %{black: 4}
      assert new_board.points[8] == %{black: 2}
    end

    test "allows moving to a self-occupied point" do
      turn = %Turn{pending_moves: [{2,8}, {2,8}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[6] == %{black: 7}
      assert new_board.points[8] == %{black: 1}
    end

    test "allows moving the same checker twice" do
      turn = %Turn{pending_moves: [{3,8}, {2,5}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[3] == %{black: 1}
      assert new_board.points[8] == %{black: 2}
    end

    # TODO: move test to move_piece?
    test "moves black checkers the correct direction" do
      turn = %Turn{pending_moves: [{3,8}, {2,8}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[5] == %{black: 1}
      assert new_board.points[6] == %{black: 6}
      assert new_board.points[8] == %{black: 1}
    end

    # TODO: move test to move_piece?
    test "moves white checkers the correct direction" do
      turn = %Turn{pending_moves: [{3,12}, {2,12}], player: :white}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[12] == %{white: 3}
      assert new_board.points[14] == %{white: 1}
      assert new_board.points[15] == %{white: 1}
    end
  end

  # describe "commit_move (invalid moves)" do
  #   test "only allows moving a distance shown on dice" do
  #     turn = %Turn{pending_moves: [{3,7}, {2,5}], player: :black}
  #     result = Board.commit_turn(%Board{}, turn)
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

  describe "commit_move (capturing pieces)" do
    @tag :skip
    test "allows capturing bare opponent pieces" do
      turn = %Turn{pending_moves: [{3,7}, {2,5}], player: :black}
      _result = Board.commit_turn(%Board{}, turn)
    end

    @tag :skip
    test "does not allow capturing doubled up opponent pieces", do: :not_implemented
  end

  describe "move_piece" do

  end
end
