# macOS Setup

Scripts and configuration to set up a MacBook Pro from scratch.

**Target:** MacBook Pro (Apple M5, 16 GB) — macOS 26 (Tahoe)

## Structure

```
macOS-setup/
├── install.sh          # Main entry point — run this first
├── Brewfile            # Declarative Homebrew package list
├── scripts/
│   ├── homebrew.sh     # Install Homebrew + packages (reads Brewfile)
│   ├── dotfiles.sh     # Symlink dotfiles into ~
│   ├── terminal.sh     # Oh My Zsh, Powerlevel10k, plugins
│   ├── vscode.sh       # VSCode extensions
│   ├── macos.sh        # macOS system preferences
│   └── dev.sh          # Dev environment (languages, tools)
└── dotfiles/
    ├── zsh/
    │   ├── .zshrc      # Zsh config (plugins, aliases, keybindings)
    │   └── .p10k.zsh   # Powerlevel10k prompt config
    └── vscode/
        └── settings.json
```

## Dotfiles

Config files live in `dotfiles/` and are symlinked into `~` by `dotfiles.sh`. Edit files in the repo — changes apply immediately since `~/.zshrc` etc. point here.

| Dotfile | Symlinked to |
|---|---|
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.p10k.zsh` | `~/.p10k.zsh` |
| `vscode/settings.json` | `~/Library/Application Support/Code/User/settings.json` |

### Shell features (`.zshrc`)

- **Theme:** Powerlevel10k
- **Plugins:** `zsh-autosuggestions`, `zsh-syntax-highlighting`
- **Natural text editing:** Option+Arrow word jump, `^A`/`^E` line start/end, `^W` delete word
- **Default editor:** `nano`
- **Aliases:** `cl` → `claude`, `vs` → `code . && exit`

## Usage

```sh
# Full setup (run once on a fresh machine)
chmod +x install.sh
sudo ./install.sh

# Or run individual scripts
./scripts/terminal.sh
./scripts/dotfiles.sh
```

## Adding something new

1. Install it manually first and confirm it works.
2. Add CLI tools to `Brewfile`; GUI apps as `cask` entries.
3. Add config to the relevant dotfile or script.
4. Commit so it's captured for next time.
