# macOS State

A modular macOS desired-state template for capturing and reapplying a machine setup.

Fork it, copy `user.config.toml.example` to `user.config.toml`, and enable only the modules you use.
This repo has two complementary jobs:

- `sync.sh` captures the current Mac into config files and a configurable snapshot folder
- `install.sh` applies the desired state on a fresh or reset Mac

## Structure

```text
macos-state/
├── install.sh                  # Apply enabled modules to a Mac
├── sync.sh                     # Capture enabled modules from the current Mac
├── user.config.toml.example    # Non-secret module toggles and defaults
├── profiles/                   # Layered Homebrew Bundle profiles
│   ├── base/Brewfile           # Core CLI tools
│   ├── languages/              # Python, R, Node profiles
│   ├── apps/                   # Browser and productivity app profiles
│   ├── ai/                     # AI tool profiles
│   ├── vscode/                 # VS Code app, extensions, and themes
│   └── personal/               # Gitignored local Brewfile overlay
├── scripts/
│   ├── homebrew.sh             # Install Homebrew and apply enabled profiles
│   ├── macos.sh                # Apply macOS defaults and browser/power settings
│   ├── dev.sh                  # Git and developer CLI setup
│   ├── r_packages.sh           # Install R packages
│   ├── python_packages.sh      # Install Python packages
│   ├── terminal.sh             # Optional Oh My Zsh, Powerlevel10k, plugins
│   ├── dotfiles.sh             # Symlink dotfiles into ~
│   ├── claude.sh               # Claude Code plugins and GSD setup
│   └── sync/                   # Capture scripts for current-machine state
└── dotfiles/                   # Source-controlled dotfiles
```

## Captured state

`sync.sh` writes current-machine state for enabled modules. The base captures are Homebrew, dotfiles, and macOS preferences; language stacks, AI tooling, browsers, and app-specific state are opt-in.

- Homebrew packages and apps to the configured snapshot folder
- Dotfiles
- macOS preferences
- VS Code extensions through Homebrew profiles
- R packages, when enabled
- Python packages, when enabled
- Claude Code settings and plugins, when enabled
- Browser-related state, when enabled
- iTerm2 profile, when enabled
- Raycast settings, when enabled
- Alfred preferences, when enabled
- BetterTouchTool presets, when enabled

## Applied state

`install.sh` applies enabled setup modules:

- Homebrew packages and apps from enabled files under `profiles/`
- macOS defaults, power settings, and default browser
- Git and developer CLI setup
- R and Python packages, when enabled
- Terminal shell tooling, when enabled
- VS Code extensions through Homebrew profiles
- Dotfile symlinks
- Claude Code plugin setup, when enabled

## Configuration

Create a local config before running either entry point:

```sh
cp user.config.toml.example user.config.toml
```

`user.config.toml` is gitignored. Use it to set personal Git details and enable optional modules:

```toml
[modules]
homebrew = true
macos    = true
dev      = true
r        = false
python   = false
terminal = false
vscode   = false
dotfiles = true
claude   = false
browser         = false
iterm2          = false
raycast         = false
alfred          = false
bettertouchtool = false

[snapshots]
path = "" # Empty = iCloud Drive if available, otherwise local Application Support
```

### Homebrew profiles

Homebrew state is split into layered profiles instead of one personal `Brewfile`. `scripts/homebrew.sh` always applies `profiles/base/Brewfile`, then applies optional profile files when their matching config keys are enabled.

Common profile toggles:

```toml
[homebrew_profiles]
base          = true
terminal      = false
python        = false
r             = false
node          = false
browsers      = false
productivity  = false
vscode        = false
vscode_themes = false
vscode_python = false
vscode_r      = false
claude        = false
personal      = true
```

If a profile-specific key is omitted, the installer falls back to the matching module when one exists. For example, `modules.python = true` enables the Python Homebrew profile and Python VS Code extensions unless you override `homebrew_profiles.python` or `homebrew_profiles.vscode_python`.

Put machine-specific packages in `profiles/personal/Brewfile.local`. That file is gitignored and is applied automatically when present unless `homebrew_profiles.personal = false`.

### Optional heavier modules

Some modules intentionally remain available but off by default because they encode stronger workflow choices:

- `terminal`: installs Oh My Zsh, Powerlevel10k, and related shell plugins
- `r`: restores or installs a broad R package stack
- `python`: installs a broad Python data/ML/LLM-oriented environment
- `vscode`: installs VS Code and a base editor extension set
- `claude`: configures Claude Code, plugins, and skills
- `browser`, `iterm2`, `raycast`, `alfred`, `bettertouchtool`: capture app-specific state when those apps are part of your setup

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
