# macOS Setup

Scripts and configuration to set up a MacBook Pro from scratch.

**Target:** MacBook Pro (Apple M5, 16 GB) — macOS 26 (Tahoe)

## Structure

```
macOS-setup/
├── install.sh          # Main entry point — run this first
├── scripts/
│   ├── homebrew.sh     # Install Homebrew + packages
│   ├── dotfiles.sh     # Symlink dotfiles / shell config
│   ├── macos.sh        # macOS system preferences
│   ├── apps.sh         # GUI apps via Homebrew Cask
│   └── dev.sh          # Dev environment (languages, tools)
├── dotfiles/           # Config files to symlink into ~
└── Brewfile            # Declarative Homebrew package list
```

## Usage

```sh
# Full setup (run once on a fresh machine)
chmod +x install.sh
./install.sh

# Or run individual scripts
./scripts/homebrew.sh
./scripts/macos.sh
```

## Adding something new

1. Install it manually first and confirm it works.
2. Add the install step to the relevant script (or create a new one under `scripts/`).
3. Commit so it's captured for next time.
