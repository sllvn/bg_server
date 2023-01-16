defmodule BgServer.Turn do
  defstruct player: :black, pending_piece: nil, dice_roll: {nil,nil}, pending_moves: []
end
