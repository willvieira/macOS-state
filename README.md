# macOS State

A reproducible & syncable record of my macOS configuration for keeping my current machine state tidy and rebuildable from scratch.

This repo has two complementary jobs:

- `sync.sh` captures the current Mac into config files and a configurable snapshot folder
- `install.sh` applies the desired state on a fresh Apple Silicon Mac

## Structure

```
macos-state/
├── install.sh                  # Apply enabled modules to a Mac
├── sync.sh                     # Capture enabled modules from the current Mac
├── user.config.toml.example    # Non-secret module toggles and defaults
├── Brewfile                    # Homebrew formulae, casks, MAS apps, VS Code extensions
├── scripts/
│   ├── homebrew.sh             # Install Homebrew and apply Brewfile
│   ├── macos.sh                # Apply macOS defaults and browser/power settings
│   ├── dev.sh                  # Git and developer CLI setup
│   ├── r_packages.sh           # Install R packages
│   ├── python_packages.sh      # Install Python packages
│   ├── terminal.sh             # Oh My Zsh, Powerlevel10k, plugins
│   ├── dotfiles.sh             # Symlink dotfiles into ~
│   ├── claude.sh               # Claude Code plugins and GSD setup
│   └── sync/                   # Capture scripts for current-machine state
├── dotfiles/                   # Source-controlled dotfiles
```

## Captured state

`sync.sh` writes current-machine state for the enabled modules:

- Homebrew packages and apps
- Dotfiles
- macOS preferences
- VS Code extensions through Brewfile
- R packages
- Python packages
- Claude Code settings and plugins
- Browser-related state
- iTerm2 profile
- Raycast settings
- Alfred preferences
- BetterTouchTool presets

## Applied state

`install.sh` applies the enabled setup modules:

- Homebrew packages and apps from `Brewfile`
- macOS defaults, power settings, and default browser
- Git and developer CLI setup
- R and Python packages
- Terminal shell tooling
- VS Code extensions through Brewfile
- Dotfile symlinks
- Claude Code plugin setup

## Configuration

Create a local config before running either entry point:

```sh
cp user.config.toml.example user.config.toml
```

`user.config.toml` is gitignored. Use it to set personal Git details and enable or disable modules:

```toml
[modules]
homebrew = true
macos    = true
dev      = true
r        = false
python   = false
terminal = true
dotfiles = true
claude   = true
browser         = true
iterm2          = false
raycast         = false
alfred          = false
bettertouchtool = false

[snapshots]
path = "" # Empty = iCloud Drive if available, otherwise local Application Support
```

## Snapshot storage

Generated snapshots are personal machine state and are ignored by git by default. `sync.sh` writes them outside the repo unless you choose a repo-local path.

Destination precedence:

1. `./sync.sh --snapshots-dir PATH` for a one-off run
2. `[snapshots].path` in `user.config.toml`
3. `~/Library/Mobile Documents/com~apple~CloudDocs/macOS State/snapshots` when iCloud Drive is available
4. `~/Library/Application Support/macOS State/snapshots` as the local fallback

Examples:

```sh
# One-off snapshot destination
./sync.sh --snapshots-dir "$HOME/Dropbox/macOS State/snapshots"

# Keep old repo-local behavior for a private checkout
./sync.sh --snapshots-dir ./snapshots
```

## Usage

```sh
# Capture the current Mac into configured snapshots
./sync.sh

# Apply desired state on a fresh or reset Mac
chmod +x install.sh sync.sh
./install.sh

# Or run individual modules
./scripts/terminal.sh
./scripts/dotfiles.sh
```

## Dotfiles

Config files live in `dotfiles/` and are symlinked into `~` by `scripts/dotfiles.sh`. Edit files in the repo — changes apply immediately since `~/.zshrc` etc. point here.

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

## Updating macOS State

1. Change or install something manually and confirm it works.
2. Run `./sync.sh` to capture current state when a sync module exists.
3. Add apply logic to the matching `scripts/*.sh` file when the state should be reproducible after reset.
4. Add or update module toggles in `user.config.toml.example` when needed.
5. Commit the repo changes so the desired state is preserved for next time.
