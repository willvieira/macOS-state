#!/usr/bin/env bash
set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"

echo "  Installing Get-Shit-Done (GSD) for Claude Code..."
npx get-shit-done-cc@latest

echo "  Registering plugin marketplaces and enabling plugins..."

if [[ ! -f "$SETTINGS" ]]; then
  mkdir -p "$(dirname "$SETTINGS")"
  echo '{}' > "$SETTINGS"
fi

python3 - "$SETTINGS" <<'EOF'
import json, sys

path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)

cfg.setdefault("extraKnownMarketplaces", {}).update({
    "everything-claude-code": {
        "source": {"source": "git", "url": "https://github.com/affaan-m/everything-claude-code.git"}
    },
    "obsidian-skills": {
        "source": {"source": "github", "repo": "kepano/obsidian-skills"}
    },
    "lean4-skills": {
        "source": {"source": "github", "repo": "cameronfreer/lean4-skills"}
    },
    "posit-dev-skills": {
        "source": {"source": "github", "repo": "posit-dev/skills"}
    },
})

cfg.setdefault("enabledPlugins", {}).update({
    "everything-claude-code@everything-claude-code": True,
    "obsidian@obsidian-skills": True,
    "lean4@lean4-skills": True,
    "posit-dev@posit-dev-skills": True,
    "open-source@posit-dev-skills": True,
    "r-lib@posit-dev-skills": True,
    "shiny@posit-dev-skills": True,
    "quarto@posit-dev-skills": True,
})

with open(path, "w") as f:
    json.dump(cfg, f, indent=4)

print("  settings.json updated")
EOF

echo "  Trimming unwanted everything-claude-code agents and skills..."

ECC_DIR="$HOME/.claude/plugins/marketplaces/everything-claude-code"

if [[ -d "$ECC_DIR" ]]; then
  # Agents to remove
  AGENTS=(
    csharp-reviewer.md
    dart-build-resolver.md
    flutter-reviewer.md
    go-build-resolver.md
    go-reviewer.md
    java-build-resolver.md
    java-reviewer.md
    kotlin-build-resolver.md
    kotlin-reviewer.md
    typescript-reviewer.md
  )
  for f in "${AGENTS[@]}"; do
    rm -f "$ECC_DIR/agents/$f"
  done

  # Skill directories to remove
  SKILLS=(
    android-clean-architecture autonomous-agent-harness autonomous-loops
    automation-audit-ops blueprint bun-runtime canary-watch
    carrier-relationship-management claude-devfleet click-path-audit
    clickhouse-io coding-standards compose-multiplatform-patterns
    connections-optimizer content-engine continuous-agent-loop
    continuous-learning csharp-testing customer-billing-ops
    customs-trade-compliance dart-flutter-patterns defi-amm-security
    django-patterns django-security django-tdd django-verification
    dmux-workflows dotnet-patterns email-ops energy-procurement
    evm-token-decimals exa-search fal-ai-media finance-billing-ops
    flutter-dart-code-review frontend-design frontend-patterns
    frontend-slides golang-patterns golang-testing hexagonal-architecture
    inventory-demand-planning java-coding-standards jpa-patterns
    kotlin-coroutines-flows kotlin-exposed-patterns kotlin-ktor-patterns
    kotlin-patterns kotlin-testing laravel-patterns laravel-plugin-discovery
    laravel-security laravel-tdd laravel-verification liquid-glass-design
    llm-trading-agent-security logistics-exception-management manim-video
    messages-ops nanoclaw-repl nextjs-turbopack nodejs-keccak256
    nutrient-document-processing nuxt4-patterns openclaw-persona-forge
    plankton-code-quality quality-nonconformance ralphinho-rfc-pipeline
    remotion-video-creation seo swift-actor-persistence swift-concurrency-6-2
    swift-protocol-di-testing swiftui-patterns ui-demo
    unified-notifications-ops video-editing videodb x-api
  )
  for s in "${SKILLS[@]}"; do
    rm -rf "$ECC_DIR/skills/$s"
  done
fi

echo "  Run /reload-plugins inside Claude Code to activate plugins."
