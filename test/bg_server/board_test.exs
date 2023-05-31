defmodule BgServer.BoardTest do
  use ExUnit.Case

  alias BgServer.{Board, Turn}

  describe "commit_turn (valid moves)" do
    test "allows moving to an unoccupied point" do
      turn = %Turn{pending_moves: [{2, 6}, {4, 8}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[4] == {:black, 2}
      assert new_board.points[6] == {:black, 4}
      assert new_board.points[8] == {:black, 2}
    end

    test "allows moving to a self-occupied point" do
      turn = %Turn{pending_moves: [{2, 8}, {2, 8}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[6] == {:black, 7}
      assert new_board.points[8] == {:black, 1}
    end

    test "allows moving the same checker twice" do
      turn = %Turn{pending_moves: [{3, 8}, {2, 5}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[3] == {:black, 1}
      assert new_board.points[8] == {:black, 2}
    end

    # TODO: move test to move_piece?
    test "moves black checkers the correct direction" do
      turn = %Turn{pending_moves: [{3, 8}, {2, 8}], player: :black}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[5] == {:black, 1}
      assert new_board.points[6] == {:black, 6}
      assert new_board.points[8] == {:black, 1}
    end

    # TODO: move test to move_piece?
    test "moves white checkers the correct direction" do
      turn = %Turn{pending_moves: [{3, 12}, {2, 12}], player: :white}
      {:ok, new_board} = Board.commit_turn(%Board{}, turn)

      assert new_board.points[12] == {:white, 3}
      assert new_board.points[14] == {:white, 1}
      assert new_board.points[15] == {:white, 1}
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
      board = %Board{points: %{%Board{}.points | 6 => {:black, 1}}}
      turn = %Turn{pending_moves: [{5, 1}, {3, 1}], player: :white}
      {:ok, new_board} = Board.commit_turn(board, turn)

      assert new_board.points[4] == {:white, 1}
      assert new_board.points[6] == {:white, 1}
      assert new_board.bar == %{black: 1}
    end

    test "properly handles capture of more than 1 piece" do
      board = %Board{points: %{%Board{}.points | 6 => {:black, 1}, 4 => {:black, 1}}, bar: %{black: 1}}
      turn = %Turn{pending_moves: [{5, 1}, {3, 1}], player: :white}
      {:ok, new_board} = Board.commit_turn(board, turn)

      assert new_board.points[4] == {:white, 1}
      assert new_board.points[6] == {:white, 1}
      assert new_board.bar == %{black: 3}
    end

    test "does not allow capturing doubled up opponent pieces" do
      board = %Board{points: %{%Board{}.points | 6 => {:black, 2}}}
      turn = %Turn{pending_moves: [{5, 1}, {3, 1}], player: :white}
      assert {:error, {:reason, :invalid_pending_moves}} = Board.commit_turn(board, turn)
    end
  end

  describe "commit_turn (bar scenarios)" do
    test "moves pieces from bar" do
      board = %Board{bar: %{black: 1}}
      turn = %Turn{pending_moves: [{3, :bar}, {4, 24}], player: :black, dice_roll: {3,4}}
      {:ok, new_board} = Board.commit_turn(board, turn)

      assert new_board.bar == %{}
      assert new_board.points[24] == {:black, 1}
      assert new_board.points[22] == {:black, 1} # barred piece, used 3
      assert new_board.points[20] == {:black, 1}
    end

    test "requires moving pieces from the bar before any other pieces" do
      board = %Board{bar: %{black: 1}}

      turn = %Turn{pending_moves: [{3, 24}, {4, 24}], player: :black, dice_roll: {3,4}}
      assert {:error, {:reason, :pieces_left_on_bar}} = Board.commit_turn(board, turn)
    end
  end

  describe "commit_turn (no valid moves)" do
  end
end
