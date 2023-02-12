defmodule BgServer.Board do
  # TODO: how to create a struct with integer keys?
  defstruct points: %{
              1 => %{white: 2},
              2 => %{},
              3 => %{},
              4 => %{},
              5 => %{},
              6 => %{black: 5},
              7 => %{},
              8 => %{black: 3},
              9 => %{},
              10 => %{},
              11 => %{},
              12 => %{white: 5},
              13 => %{black: 5},
              14 => %{},
              15 => %{},
              16 => %{},
              17 => %{white: 3},
              18 => %{},
              19 => %{white: 5},
              20 => %{},
              21 => %{},
              22 => %{},
              23 => %{},
              24 => %{black: 2}
            },
            bar: %{}

  def empty_board do
    %{
      1 => %{white: 2},
      6 => %{black: 5},
      8 => %{black: 3},
      12 => %{white: 5},
      13 => %{black: 5},
      17 => %{white: 3},
      19 => %{white: 5},
      24 => %{black: 2}
    }
  end
end
