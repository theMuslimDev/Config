# Personal Dotfiles

Personal configuration for Ghostty, tmux, and zsh. Meant to live at
`~/.config`, merged alongside everything else there. `nvim/` is deliberately
excluded (see `.gitignore`); it's tracked in its own repo at
`~/.config/nvim`, kept separate on purpose.

> [!WARNING]
> This configuration is tailored for me and my machine. You are more
> than welcome to browse the code, steal snippets, or fork it, but **use it at
> your own risk**. I make no guarantees that it will work seamlessly on your
> system, and I frequently change things without warning!

## Layout

- `ghostty/` — terminal config + themes, read directly from `~/.config/ghostty`
- `.tmux.conf` — read directly from `~/.config/.tmux.conf`
- `zshrc/.zshrc` — shell config; zsh reads `.zshrc` from `$HOME`, not
  `~/.config`, so this is symlinked into place (see below)
- `swift-format.md` — notes on setting up SwiftFormat for Xcode

## Setup on a new machine

1. Clone straight into `~/.config`:

   ```bash
   git clone git@github.com:theMuslimDev/Config.git "$HOME/.config"
   ```

2. Symlink `.zshrc` into place:

   ```bash
   mv ~/.zshrc ~/.zshrc.bak 2>/dev/null # back up whatever's there first
   ln -s ~/.config/zshrc/.zshrc ~/.zshrc
   ```

3. Restart the shell / terminal. Ghostty and tmux need no extra symlinking:
   they already read their configs straight from `~/.config`.
