# BgServer

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## TODO

- [x] hook up capturing pieces to board liveview
- [ ] re-enter board from bar (must play pieces from bar before any other piece can move)
    - If a player has pieces on the bar, they must be moved before any other pieces
- [ ] no possible moves
    - Player must play both dice if possible
    - If no valid moves exist, turn is over
- [ ] bearing off checkers
    - If all remaining pieces are in home board, player is in bearing-off mode
- [ ] game-over detection
- [ ] better board display for white
- [ ] UX niceities (play sound when it's your turn)
- [ ] pips-remaining counter