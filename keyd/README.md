# keyd

System-wide keyboard remapping via [keyd](https://github.com/rvaiya/keyd).
Works identically on Arch and Mint/Debian because keyd operates at the
kernel/evdev level (display-server agnostic).

## What it does

Holding **Alt** turns the home-row cluster into a navigation layer:

| Keys        | Action                          |
| ----------- | ------------------------------- |
| `i/j/k/l`   | up / left / down / right        |
| `e` / `a`   | End / Home                      |
| `d` / `f`   | Backspace / Delete              |
| `u/o/p/;`   | word/paragraph motions (Alt+arrow) |

Alt still works normally for everything else (Alt+Tab, Alt+F4, …).

## Install (per box)

```bash
cd ~/.dotfiles/keyd && ./install.sh
```

This installs keyd (pacman on Arch, apt-or-source on Mint), symlinks
`/etc/keyd/default.conf` → this repo's `etc/keyd/default.conf`, and enables
the service. Idempotent — safe to re-run.

## Syncing a change

The live config is a symlink into this repo, so on every box just:

```bash
cd ~/.dotfiles && git pull && sudo keyd reload
```

`keyd` does **not** auto-reload — `sudo keyd reload` applies edits.

## Layout note

This is a `keyd` config, not an XKB layout, so it is independent of your
selected keyboard layout (us/no/…). Bindings reference physical keys.
