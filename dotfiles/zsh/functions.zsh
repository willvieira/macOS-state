# Shell functions, sourced from .zshrc

# Open code/script files in Zed, everything else in the terminal editor
edit() {
  if [[ $# -eq 0 ]]; then
    "$EDITOR"
    return
  fi

  case "$1" in
    *.applescript|*.awk|*.bash|*.c|*.cc|*.cpp|*.cs|*.css|*.go|*.h|*.hpp|*.html|*.java|*.js|*.jsx|*.lua|*.mjs|*.php|*.pl|*.ps1|*.py|*.rb|*.rs|*.sh|*.swift|*.ts|*.tsx|*.zsh)
      command zed --wait "$@"
      ;;
    *)
      "$EDITOR" "$@"
      ;;
  esac
}

# Reinstall the AIMS Claude plugin and its tools from the insilecloud/aims marketplace
aimsup() {
  local aims=~/.claude/plugins/marketplaces/insileco-aims tool
  claude plugin marketplace remove insileco-aims
  claude plugin marketplace add insilecloud/aims &&
    claude plugin install aims@insileco-aims &&
    claude plugin update aims@insileco-aims || return 1
  for tool in $aims/tools/*/(N); do
    # likuid-mcp has its own installer (below), not a uv tool
    [[ $tool == */likuid-mcp/ ]] && continue
    uv tool install --reinstall "$tool"
  done
  # only refresh likuid-mcp if the mailbox setup was done before
  [[ -d ~/.local/share/aims/likuid-mcp ]] && bash $aims/scripts/likuid-imap/install.sh
}
