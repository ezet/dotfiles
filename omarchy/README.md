# omarchy

Omarchy-specific automation that isn't part of a Hyprland/Waybar config.

| File | Purpose |
| ---- | ------- |
| `.config/omarchy/hooks/post-update.d/dotfiles-sync` | After every `omarchy update`: fast-forward this repo and `keyd reload`, so a config change committed on one device applies on the others unattended. |

Omarchy runs `omarchy-hook post-update` at the end of `omarchy update`, which
executes every non-`.sample` file in `hooks/post-update.d/`. Using the `.d/`
directory (rather than a single `post-update` file) keeps this composable with
any other post-update hook.

The hook is deliberately conservative:

- It **skips the pull** if the repo has uncommitted changes — a system update
  will never clobber work in progress.
- It **only reloads keyd** if `/etc/keyd/default.conf` genuinely resolves to
  this repo; otherwise it tells you to run `~/.dotfiles/.keyd/install.sh`.
- The reload uses `sudo -n` (never prompts). It's a no-op unless
  `/etc/sudoers.d/keyd-reload` exists, which `.keyd/install.sh` installs.

This package is Omarchy-only — exclude it on Mint/Debian boxes.
