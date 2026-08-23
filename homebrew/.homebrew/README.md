# ~/.homebrew

`trust.json` records which third-party tap formulae Homebrew is allowed to
load. Homebrew 6 refuses them by default — a tap is arbitrary code that runs at
install time, so this is a real trust decision rather than a formality.

Currently trusted:

- `felixkratz/formulae/borders` — JankyBorders. Trusted at formula level, not
  tap level, so nothing else from that tap can be installed without another
  explicit decision.

Version-controlled so a fresh machine reproduces the decision instead of
hitting an opaque "untrusted tap" error mid-bootstrap. To revoke, delete the
entry and run `brew untap felixkratz/formulae`.
