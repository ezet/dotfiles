# dotfiles

Personal configuration, managed with [omadot](https://github.com/tomhayes/omadot)
— a thin GNU Stow wrapper. Each **non-hidden** top-level directory is a Stow
*package* whose contents mirror `$HOME`; `omadot put <pkg>` symlinks it into
place, `omadot get <pkg>` imports a live config back into the repo.

## Packages

| Package  | Managed by                 | Portable?                          | Notes |
| -------- | -------------------------- | ---------------------------------- | ----- |
| `hypr`   | omadot/stow → `~/.config`  | ❌ Omarchy / Hyprland (Wayland, Arch) | Sources `~/.local/share/omarchy/…`; meaningless without Omarchy. |
| `waybar` | omadot/stow → `~/.config`  | ❌ Omarchy / Hyprland               | Wayland status bar; Mint/Cinnamon doesn't use it. |
| `.keyd`  | **own installer** (not omadot) | ✅ any Linux (Arch + Mint)      | Root-owned `/etc/keyd`. Hidden so omadot auto-skips it. See [`.keyd/README.md`](.keyd/README.md). |
| `omarchy` | omadot/stow → `~/.config`  | ❌ Omarchy only                     | `post-update` hook: auto-pull this repo + `keyd reload` after `omarchy update`. See [`omarchy/README.md`](omarchy/README.md). |

## Bootstrapping a machine

Install omadot + GNU Stow, then clone this repo:

```bash
curl -fsSL https://raw.githubusercontent.com/tomhayes/omadot/main/install.sh | bash
# stow:  sudo pacman -S stow   (Arch)   |   sudo apt install stow   (Mint/Debian)
git clone https://github.com/ezet/dotfiles ~/.dotfiles
```

**Just want the keyd remapper on a box?** That needs neither omadot nor stow —
one line, any Linux:

```bash
git clone https://github.com/ezet/dotfiles ~/.dotfiles && ~/.dotfiles/.keyd/install.sh
```

### Omarchy / Arch (Hyprland)

```bash
cd ~/.dotfiles
omadot put --all      # stows hypr, waybar, …  (.keyd auto-skipped — it's hidden)
./.keyd/install.sh    # installs keyd + symlinks /etc/keyd/default.conf
```

### Linux Mint / any non-Hyprland box (Cinnamon, X11, …)

`hypr`, `waybar` and `omarchy` are Omarchy/Hyprland-only — exclude them:

```bash
cd ~/.dotfiles
omadot put --all --exclude=hypr,waybar,omarchy   # skip the Wayland/Omarchy packages
./.keyd/install.sh                        # keyd works everywhere
```

## Syncing changes across boxes

On Omarchy boxes this is **automatic**: the `omarchy` package installs a
`post-update` hook that fast-forwards this repo and reloads keyd at the end of
every `omarchy update`. It skips the pull if the repo has uncommitted changes.

To sync by hand (or on non-Omarchy boxes):

```bash
cd ~/.dotfiles && git pull
omadot put <changed-package>   # re-stow only if the pull ADDED files to a package
sudo keyd reload               # apply changes to .keyd/etc/keyd/default.conf
```

(The live `/etc/keyd/default.conf` is a symlink into this repo, so a `git pull`
already updates it — keyd just needs `sudo keyd reload` to pick it up. After
`.keyd/install.sh` that reload is passwordless, via `/etc/sudoers.d/keyd-reload`.)

## Why `.keyd` is hidden (auto-exclusion)

omadot has **no ignore-file** — its only exclusion is the `--exclude=` flag,
which you'd have to remember on every `put --all`. But `omadot put --all` and
`omadot list` glob only **non-hidden** top-level dirs (`"$DOTFILES_DIR"/*`, and
bash doesn't match dot-dirs). Naming the package `.keyd` therefore makes it
**always invisible to omadot on every machine** — no `--exclude` needed.

This is required because keyd isn't a `$HOME`-stow package: its config belongs
in root-owned `/etc/keyd`. Stowing it would scatter junk symlinks (`~/etc`,
`~/install.sh`, …) in your home dir, so it ships with its own installer instead.
